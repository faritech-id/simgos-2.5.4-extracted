<?php
namespace Aplikasi\V1\Rpc\Authentication;

use Laminas\Mvc\Controller\AbstractActionController;

use Laminas\Authentication\Storage\Session as StorageSession;
use Laminas\Authentication\AuthenticationService;
use Laminas\Authentication\Adapter\DbTable\CredentialTreatmentAdapter as AuthAdapter;
use Laminas\Session\AbstractContainer as ConSession;
use Laminas\Captcha\Image;

use Laminas\Json\Json;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\System;
use Aplikasi\Password;
use Aplikasi\V1\Rest\PenggunaLog\Service as PenggunaLogService;
use Aplikasi\V1\Rest\PropertiConfig\Service as PropertiConfigService;
use Aplikasi\V1\Rest\Pengguna\PenggunaService;

use \DateTime;
use \DateTimeZone;

use DBService\Crypto;
use Ramsey\Uuid\Uuid;

class AuthenticationController extends AbstractActionController
{
    private $manager;
	private $auth;
	private $storageSession;
	private $tokenStorage;
	private $penggunaLog;
	private $propertyConfig;
	private $captchaImage;
	private $penggunaService;
	private $lockAppStorage;
	private $https = false;

	private $crypto;

	private $config;

	public function __construct($controller) {
		$this->config = $controller->get('Config');
		$this->config = $this->config['services'];

		$this->auth = new AuthenticationService();
		$this->penggunaLog = new PenggunaLogService();
		$this->storageSession = new StorageSession("AUTHENTICATION", "VALIDATE");
		$this->tokenStorage = new StorageSession("AUTHENTICATION", "TOKEN");
		$this->propertyConfig = new PropertiConfigService();
		$this->penggunaService = new PenggunaService();

		$this->lockAppStorage = new StorageSession("LOCKAPP", "STATUS");

		$this->captchaImage = new Image();

		$this->crypto = new Crypto();

		$this->https = $_SERVER['REQUEST_SCHEME'] == "https";
	}

    public function loginAction($params = null)
    {
		$request = $this->getRequest();
		if($request->getMethod() == 'GET') {
			$this->response->setStatusCode(405);
			return [];
		}
		
		$this->manager = ConSession::getDefaultManager();
		
		$data = json_decode($request->getContent());
		if(isset($data->INTEGRATION)) {
			$data = base64_decode($data->DATA);
			$data = json_decode($data);
			$data->PASSWORD = base64_decode($data->PASSWORD);		
		}
		
		if(isset($params)) {
			$data = json_decode($params);
		}

		
		// input validation
		$dt = (array) $data;
		if(count($dt) == 0 || empty($dt["LOGIN"]) || empty($dt["PASSWORD"])) {
			return [
				'success' => false,
				'message' => "Input Validation",
				'detail' => "Field LOGIN dan PASSWORD tidak boleh kosong",
				'data' => null
			];
		}
		
		$db = DatabaseService::get("SIMpel");
		$adapter = $db->getAdapter();
	
		$_data = $this->storageSession->read();
		$sysdate  = null;

		try {
			$sysdate = System::getSysDate($adapter);
		
			$dt = new DateTime(null, new DateTimeZone('UTC'));
			$ts = $dt->getTimestamp();

			$defaultCounter = $this->getPropertyConfig(["ID" => 38]);
			$lockTime = $this->getPropertyConfig(["ID" => 37]);
			$useCaptcha = $this->getPropertyConfig(["ID" => 39]);			

			if(count($defaultCounter) > 0) $defaultCounter = (int) $defaultCounter[0]["VALUE"];
			else $defaultCounter = 3;

			if(count($lockTime) > 0) $lockTime = $lockTime[0]["VALUE"];
			else $lockTime = "00:00:45";

			if(count($useCaptcha) > 0) $useCaptcha = $useCaptcha[0]["VALUE"];
			else $useCaptcha = "FALSE";

			if($useCaptcha == "FALSE") {			
				if(isset($this->config["enableCaptcha"])) $useCaptcha = $this->config["enableCaptcha"] ? "TRUE" : "FALSE";
			}

			$waktu = explode(" ", $sysdate)[1];
		} catch(\Exception $e) {
			return [
				'success' => false,
				'message' => "Error Access DB",
				'detail' => $e->getMessage(),
				'data' => null
			];
		}

		if($_data) {
			$dt = (array) $_data;
			if($useCaptcha == "TRUE") {
				$fieldExists = true;
				if(!empty($dt["CAPTCHA"])) {
					if(empty($dt["COUNTER"])) {
						$dt["COUNTER"] = 0;
						$_data = json_decode(json_encode($dt));
						$dt = (array) $_data;
					}
					$post = (array) $data;
					if(empty($post["CAPTCHA"])) {
						return [
							'success' => false,
							'message' => "Input Validation",
							'detail' => "Field CAPTCHA tidak boleh kosong",
							'data' => null
						];
					}
				} else {
					return [
						'success' => false,
						'message' => "Input Validation",
						'detail' => "Anda belum melakukan generate CAPTCHA",
						'data' => null
					];
				}
			}
			if(!empty($dt["COUNTER"])) {
				if($dt["COUNTER"] >= $defaultCounter) {
					$currentTime = System::getDiffTime($adapter, $dt["WAKTU"], $waktu);
					$sisa = System::getDiffTime($adapter, $currentTime, $lockTime);
					if($currentTime > $lockTime) {
						$dt["COUNTER"] = 0;
						unset($dt["WAKTU"]);
						$_data = json_decode(json_encode($dt));
						$dt = (array) $_data;
					} else {
						return [
							'success' => false,
							'message' => "Login Locked",
							'detail' => "Login terkunci selama: ".$sisa,
							'timeLock' => $sisa,
							'data' => null
						];
					}
				}
			}
			if($useCaptcha == "TRUE") {
				$dt = (array) $_data;
				if(!empty($dt["CAPTCHA"])) {
					if(empty($dt["COUNTER"])) {
						$dt["COUNTER"] = 0;
						$_data = json_decode(json_encode($dt));
						$dt = (array) $_data;
					}
					$counter = $defaultCounter;
					if(!$this->captchaImage->isValid([
						"id" => $dt["CAPTCHA"]->ID,
						"input" => $data->CAPTCHA
					])) {
						$dt["COUNTER"] = $dt["COUNTER"] + 1;
						$counter = $counter -$dt["COUNTER"];
						if($counter == 0) {
							if(empty($dt["WAKTU"])) {
								$dt["WAKTU"] = $waktu;
								$dt = json_decode(json_encode($dt));
							}
						} 
						$this->storageSession->write($dt);

						$detil = "Kode Captcha Anda tidak benar.";
						if($counter == 0) $detil .= "<br>Anda sudah tidak memiliki kesempatan lagi";
						else $detil .= "<br>Kesempatan anda tinggal ".$counter." kali";
						$return  = [
							'success' => false,
							'message' => "Invalid Captcha",
							'detail' => $detil,
							'data' => null
						];
						if($counter == 0) $return["timeLock"] = $lockTime;
						return $return;
					}
				} else {
					return [
						'success' => false,
						'message' => "Input Validation",
						'detail' => "Anda belum melakukan generate CAPTCHA",
						'data' => null
					];
				}
			}
		}

		$key = null;
		if(!$this->auth->hasIdentity()) {									
			$result = $this->doAuthenticate($adapter, $data, Password::TYPE_ENCRYPT_MD5_WITH_KEY);
			if(!$this->auth->hasIdentity()) $result = $this->doAuthenticate($adapter, $data, Password::TYPE_ENCRYPT_MD5_ONLY);
			if(!$this->auth->hasIdentity()) $result = $this->doAuthenticate($adapter, $data, Password::TYPE_ENCRYPT_SHA256_PASS_HASH);
			
			$success = true;
			$message = 'login ';
			$detil = "";
			$id = $nama = $data = null;

			if(!$result["result"]->isValid()) {
				foreach($result["result"]->getMessages() as $msg) {
					$message .= $msg;
				}
				$success = false;

				$counter = $defaultCounter;
				if($_data) {
					$dt = (array) $_data;
					if(empty($dt["COUNTER"])) $dt["COUNTER"] = 0;
					$dt["COUNTER"] = $dt["COUNTER"] + 1;
					$counter = $counter - $dt["COUNTER"];
					if($counter == 0) {
						if(empty($dt["WAKTU"])) {
							$dt["WAKTU"] = $waktu;
							$dt = json_decode(json_encode($dt));
						}
					}
					$this->storageSession->write($dt);
				} else {
					$_data = json_decode(json_encode(["COUNTER" => 1]));
					$counter -= 1;
					$this->storageSession->write($_data);
				}
				$detil = "ID Pengguna dan Kata Sandi yang anda masukan salah.";
				if($counter == 0) $detil .= "<br>Anda sudah tidak memiliki kesempatan lagi";
				else $detil .= "<br>Kesempatan anda tinggal ".$counter." kali";
				$return = [
					'success' => $success,
					'message' => $message,
					'detail' => $detil,
					'data' => $data
				];
				if($counter == 0) $return["timeLock"] = $lockTime;

				return $return; 
			} else {
				$this->storageSession->clear();
				if($this->auth->hasIdentity()) {				
					$row = (array) $result["adapter"]->getResultRowObject(["ID", "NAMA", "LOGIN", "NIP", "NIK", "JENIS", "LOCK_APP", "MASA_AKTIF"]);
					$privilages = [];
					$integrasi = [];
					$_tgl = str_replace("-", "", explode(" ", $sysdate)[0]);
					$aktif = str_replace("-", "", $row['MASA_AKTIF']);
					if($_tgl > $aktif && $row["JENIS"] == 2) { // Eksternal User
						$this->auth->clearIdentity();
						$success = false;
						$message = "Masa Aktif Pengguna";
						$detil = "Masa Aktif Pengguna Anda telah berakhir<br>Silahkan hub. Admin";
						$data = null;
					} else {
						$nama = $row['NAMA'];
						$login = $row['LOGIN'];
						$id = $row['ID'];
						$jenis = $row['JENIS'];
						$nik = $row['NIK'];
						$nip = $row['NIP'];
						$privilages = $this->getUserPrivilages($adapter, $id);						
						$propertyConfig = $this->getPropertyConfig();
						$integrasi = $this->getIntegrasi($adapter);
						$nomor = $this->getTransaksiKasir($adapter, $id);
						$penggunaRuangan = $this->getRuanganPengguna($adapter, $id);
						$privilagesPencarian = $this->getUserPrivilagesPencarian($adapter, $id);
						$uam = $this->getUserAksesModule($adapter, $id);
					
						$storage = $this->auth->getStorage();

						$data = [
							'ID' => $id, 'NAME' => $nama, 'LGN' => $login, 'JNS' => $jenis, 
							'NIK' => $nik, 'NIP' => $nip, 'TIMESTAMP' => $ts, 'XPRIV' => $privilages, 
							'XITR' => $integrasi, 'PC' => $propertyConfig, 'NO_TRX_KSR' => $nomor, 
							'RUANGANS' => $penggunaRuangan, 'XPRIVPENCARIAN' => $privilagesPencarian, 
							'XUAM' => $uam, 'SYSDATE' => $sysdate, 'LAPP' => $row['LOCK_APP']
						];
						$storage->write(Json::decode(Json::encode($data)));

						if($this->https) {
							$uuid = Uuid::uuid4()->toString();
							$key = $this->crypto->generateKey($uuid, 32, false);
							$this->crypto->setKey($key);
							$content = base64_encode(json_encode($data));
							$data = $this->crypto->encrypt($content, true);
							$this->tokenStorage->write(json_decode(json_encode(["TOKEN" => $key])));
						}
					}
				}
			}
		} else {
			$message = 'logged';
			$success = true;
			$detil = "Success";
			$data = $this->auth->getIdentity();
			$uam = isset($data->XUAM) ? $data->XUAM : []; 
			$lapp = isset($data->LAPP) ? $data->LAPP : 1; 
			$id = $data->ID;
			$data = [
				'ID' => $data->ID, 'NAME' => $data->NAME, 'LGN' => $data->LGN, 'JNS' => $data->JNS, 
				'NIK' => isset($data->NIK) ? $data->NIK : null, 'NIP' => isset($data->NIP) ? $data->NIP : null, 'TIMESTAMP' => $ts, 'XPRIV' => $data->XPRIV, 
				'XITR' => $data->XITR, 'PC'=>$data->PC, 'NO_TRX_KSR' => $data->NO_TRX_KSR, 
				'RUANGANS' => $data->RUANGANS, 'XUAM' => $uam, 'SYSDATE' => $sysdate, 'LAPP' => $lapp
			];

			if($this->https) {
				$key = $this->tokenStorage->read();
				if($key) {
					$key = (array) $key;
					// cek token here
					$this->crypto->setKey($key["TOKEN"]);
					$content = base64_encode(json_encode($data));
					$data = $this->crypto->encrypt($content, true);
				} else {
					$message = 'Token not found';
					$success = false;
					$detil = "Not Found";
					$data = null;
				}
			}
		}
		
		if($success) {
			$forwardHost = $request->getServer('HTTP_X_FORWARDED_FOR');
			$location = $forwardHost ? $forwardHost : $request->getServer('REMOTE_ADDR');
			$userAgent = $request->getServer('HTTP_USER_AGENT');
			$server = $request->getServer('SERVER_ADDR');
			$this->penggunaLog->simpanData(
				[
					"PENGGUNA" => $id,
					"TANGGAL_AKSES" => new \Laminas\Db\Sql\Expression('NOW()'),
					"LOKASI_AKSES" => $location,
					"TUJUAN_AKSES" => $server,
					"AGENT" => $userAgent
				], true, false
			);
		}

		$result = [
            'success' => $success,
			'message' => $message,
			'detail' => $detil,
            'data' => $data
		];
		if($success) $result["access_token"] = $key;
		
		return $result;
    }
	
	private function doAuthenticate($adapter, $data, $passwordType) {
		$pass = $data->PASSWORD;
		if($passwordType == Password::TYPE_ENCRYPT_SHA256_PASS_HASH) {
			$datas = $this->penggunaService->load([
				"LOGIN" => $data->LOGIN,
				'STATUS' => 1
			], ['JENIS', 'PASSWORD']);
			if(count($datas) > 0) {
				if(Password::verify($datas[0]["PASSWORD"], $pass)) $pass = $datas[0]["PASSWORD"];
			}
		} else {
			$pass = Password::encrypt($data->PASSWORD, $passwordType);
		}

	    $authAdapter = new AuthAdapter(
	        $adapter,
	        "pengguna",
	        'LOGIN',
	        'PASSWORD'
		);
	    
	    if(isset($data->ENCRYPTED)) $pass = $data->PASSWORD;
		$authAdapter->setIdentity($data->LOGIN)
	    ->setCredential($pass);
	    $select = $authAdapter->getDbSelect();
	    $select->where('STATUS = 1');
	    $result = $this->auth->authenticate($authAdapter);
	    return [
			"result" => $result,
			"adapter" => $authAdapter
		];
	}
	
	private function getUserPrivilages($adapter, $pengguna) {
		$stmt = $adapter->query('
			SELECT gpam.MODUL
			  FROM aplikasi.pengguna_akses pa, aplikasi.group_pengguna_akses_module gpam
			 WHERE pa.GROUP_PENGGUNA_AKSES_MODULE = gpam.ID
		       AND pa.STATUS = 1 AND gpam.STATUS = 1
			   AND pa.PENGGUNA = ?');
		$result = $stmt->execute([$pengguna]);
		$data = [];
		foreach($result as $rst) {
			$val = $rst['MODUL'];
			$data[$val] = $val;
		}
		return $data;
	}
	
	private function getUserAksesModule($adapter, $pengguna) {
	    $stmt = $adapter->query('
			SELECT DISTINCT m.ID, m.NAMA, m.LEVEL, m.DESKRIPSI, m.CLASS, m.ICON_CLS
					, m.HAVE_CHILD, m.MENU_HOME, m.PACKAGE_NAME, m.CONFIG, m.MENU_MASTER, m.IDX
              FROM aplikasi.pengguna_akses pa
              		 , aplikasi.group_pengguna_akses_module gpam
              		 , aplikasi.modules m
             WHERE pa.GROUP_PENGGUNA_AKSES_MODULE = gpam.ID
               AND pa.STATUS = 1 AND gpam.STATUS = 1
               AND m.ID = gpam.MODUL AND m.`STATUS` = 1
               AND pa.PENGGUNA = ?
             ORDER BY m.IDX');
	    $result = $stmt->execute([$pengguna]);
	    $data = [];
	    foreach($result as $rst) {
	        $data[] = base64_encode(json_encode($rst));
	    }
	    return base64_encode(json_encode($data));
	}
	
	private function getUserPrivilagesPencarian($adapter, $pengguna) {
		$stmt = $adapter->query('
			SELECT DISTINCT md.*
			  FROM aplikasi.pengguna_akses pa, aplikasi.group_pengguna_akses_module gpam, aplikasi.modules md
			 WHERE pa.GROUP_PENGGUNA_AKSES_MODULE = gpam.ID
		       AND pa.STATUS = 1 AND gpam.STATUS = 1
			   AND pa.PENGGUNA = ? AND gpam.MODUL LIKE "240101%"
			   AND md.LEVEL = 4
			   AND md.ID = gpam.MODUL');
		$result = $stmt->execute([$pengguna]);
		$data = [];
		foreach($result as $rst) {
			$data[] = $rst;
		}
		return $data;
	}
	
	private function getRuanganPengguna($adapter, $pengguna) {
		$stmt = $adapter->query("
			SELECT * FROM (
				SELECT IF(NOT dr.ID IS NULL, dr.RUANGAN, 
							IF(NOT sr.ID IS NULL, sr.RUANGAN,
									IF(NOT pru.ID IS NULL, pru.RUANGAN, ''))) RUANGAN
				  FROM aplikasi.pengguna p
						 LEFT JOIN master.dokter d ON d.NIP = p.NIP
						 LEFT JOIN master.dokter_ruangan dr ON dr.DOKTER = d.ID AND dr.STATUS = 1
						 LEFT JOIN master.staff s ON s.NIP = p.NIP
						 LEFT JOIN master.staff_ruangan sr ON sr.STAFF = s.ID AND sr.STATUS = 1
						 LEFT JOIN master.perawat pr ON pr.NIP = p.NIP
						 LEFT JOIN master.perawat_ruangan pru ON pru.PERAWAT = pr.ID AND pru.STATUS = 1
				 WHERE p.ID = ?
				) pr, master.ruangan r 
			WHERE pr.RUANGAN = r.ID
			  AND r.STATUS = 1");
		$result = $stmt->execute([$pengguna]);
		$data = [];
		foreach($result as $rst) {
			$data[] = $rst;
		}
		return $data;
	}
	
	private function getPropertyConfig($params = []) {
		$params["start"] = 0;
		$params["limit"] = 1000;
		return $this->propertyConfig->load($params, ["ID", "VALUE"]);
	}
	
	private function getIntegrasi($adapter) {
		$stmt = $adapter->query('
			SELECT * FROM aplikasi.integrasi WHERE STATUS = 1');
		$result = $stmt->execute();
		$data = [];
		foreach($result as $rst) {
			$data[] = $rst;
		}
		return $data;
	}
	
	public function isAuthenticateAction() 
	{        
		$request = $this->getRequest();
		
		$message = 'logged';
		$success = true;
		$data = null;
		$data = $this->auth->getIdentity();		
		
		if($this->auth->hasIdentity()) {
			$data = $this->auth->getIdentity();
			$db = DatabaseService::get("SIMpel");
			$adapter = $db->getAdapter();			
			$nomor = $this->getTransaksiKasir($adapter, $data->ID);
			$integrasi = $this->getIntegrasi($adapter);
			$propertyConfig = $this->getPropertyConfig();
			$sysdate = System::getSysDate($adapter);
			$privilages = $this->getUserPrivilages($adapter, $data->ID);	
			$penggunaRuangan = $this->getRuanganPengguna($adapter, $data->ID);
			$privilagesPencarian = $this->getUserPrivilagesPencarian($adapter, $data->ID);
			$uam = $this->getUserAksesModule($adapter, $data->ID);
			$nip = isset($data->NIP) ? $data->NIP : null;
			$lapp = isset($data->LAPP) ? $data->LAPP : 1;
			
			$storage = $this->auth->getStorage();
			
			$data = [
				'ID' => $data->ID, 'NAME' => $data->NAME, 'LGN' => $data->LGN, 'JNS' => $data->JNS, 
				'NIK' => $data->NIK, 'NIP' => $nip, 'XPRIV' => $privilages, 
				'XITR' => $integrasi, 'PC' => $propertyConfig,
				'RUANGANS' => $penggunaRuangan, 'XPRIVPENCARIAN' => $privilagesPencarian, 
				'XUAM' => $uam, 'NO_TRX_KSR' => $nomor, 'SYSDATE' => $sysdate, 'LAPP' => $lapp
			];
			$storage->write(Json::decode(Json::encode($data)));

			if($this->https) {
				$key = $this->tokenStorage->read();
				if($key) {
					$key = (array) $key;
					// cek token here
					$this->crypto->setKey($key["TOKEN"]);
					$content = (json_encode($data));
					$data = $this->crypto->encrypt($content, true, true);
				} else {
					$data = null;
					$success = false;
					$message = 'Invalid access token';
				}
			}
		} else {			
			$success = false;
			$message = 'not login';
		}
				
        return [
			'success' => $success,
			'message' => $message,
            'data' => $data,
		];
	}
	
	private function getTransaksiKasir($adapter, $pengguna) {
		$stmt = $adapter->query('
			SELECT NOMOR
			  FROM pembayaran.transaksi_kasir
			 WHERE KASIR = ?
			   AND STATUS = 1
			 ORDER BY BUKA DESC LIMIT 1');
		$results = $stmt->execute([$pengguna]);
		$row = $results->current();
		$nomor = null;
		if($row) {
			$nomor = $row['NOMOR'];
		}
		return $nomor;
	}
	
	public function logoutAction() {
		if($this->tokenStorage) $this->tokenStorage->clear();
		$this->auth->clearIdentity();
		$this->captchaAction();
		
		return [
            'success' => true,
			'message' => 'logout',
            'data' => null
		];
	}

	public function captchaAction() {
		$useCaptcha = $this->getPropertyConfig(["ID" => 39]);
		$font = $this->getPropertyConfig(["ID" => 40]);
		$dnl = $this->getPropertyConfig(["ID" => 44]);
		$lnl = $this->getPropertyConfig(["ID" => 45]);

		if(count($useCaptcha) > 0) $useCaptcha = $useCaptcha[0]["VALUE"];
		else $useCaptcha = "FALSE";
		if($useCaptcha == "FALSE") {			
			if(isset($this->config["enableCaptcha"])) $useCaptcha = $this->config["enableCaptcha"] ? "TRUE" : "FALSE";
		}
		if($useCaptcha != "TRUE") return [];

		if(count($font) > 0) $font = $font[0]["VALUE"];
		$dir = realpath('.').'/logs/';
		$this->captchaImage->setImgDir($dir);
		$this->captchaImage->setFont("public/fonts/".$font);
		$this->captchaImage->setWidth(150);
		$this->captchaImage->setFontSize(25);
		$this->captchaImage->setWordlen(6);
		$this->captchaImage->setDotNoiseLevel(count($dnl) > 0 ? (int) $dnl[0]["VALUE"] : 0);
		$this->captchaImage->setLineNoiseLevel(count($lnl) > 0 ? (int) $lnl[0]["VALUE"] : 0);
		$id = $this->captchaImage->generate();
		
		$_data = $this->storageSession->read();
		$dt = (array) $_data;
		$dt["CAPTCHA"] = [
			"ID" => $id
		];
		$dt = json_decode(json_encode($dt));
		$this->storageSession->write($dt);

		$ext = str_replace(".", "", $this->captchaImage->getSuffix());
		$fn = $id . "." . $ext;
		$tipe = "image/".$ext;

		$content = file_get_contents($dir.$fn);

		$this->getResponse()->setContent($content);
	    $headers = $this->getResponse()->getHeaders();
	    $headers->clearHeaders()
	    ->addHeaderLine('Content-Type', $tipe)
	    ->addHeaderLine('Content-Length', strlen($content));
		unlink($dir.$fn);
	    return $this->getResponse();
	}

	public function useCaptchaAction() {
		$useCaptcha = $this->getPropertyConfig(["ID" => 39]);
		if(count($useCaptcha) > 0) {
			if($useCaptcha[0]["VALUE"] == "FALSE") {			
				if(isset($this->config["enableCaptcha"])) $useCaptcha[0]["VALUE"] = $this->config["enableCaptcha"] ? "TRUE" : "FALSE";
			}
			return [
				"status" => $useCaptcha[0]["VALUE"] == "TRUE"
			];
		} else return [
			"status" => false
		];
	}

	public function lockAppAction() 
	{        
		$request = $this->getRequest();
		if($this->auth->hasIdentity()) {
			$user = $this->auth->getIdentity();
			$content = (array) json_decode($request->getContent());
			if(!isset($content["ID"])) {
				$message = 'Id tidak boleh kosong';
				$success = false;
			} else {
				if($user->ID != $content["ID"]) {
					$message = 'Id tidak valid';
					$success = false;
				} else {
					$content["LOCK"] = true;
					$this->lockAppStorage->write($content);
					$message = 'lock';
					$success = true;
				}
			}
		} else {			
			$success = false;
			$message = 'not login';
		}
				
        return [
			'success' => $success,
			'message' => $message
		];
	}

	public function isLockAppAction() 
	{        
		if($this->auth->hasIdentity()) {
			$data = $this->lockAppStorage->read();
			$success = true;
			if($data) {
				$message = $data["LOCK"] ? "lock" : "unlock";
			} else {
				$message = 'unlock';
			}
		} else {			
			$success = false;
			$message = 'not login';
		}
				
        return [
			'success' => $success,
			'message' => $message
		];
	}

	public function unlockAppAction() 
	{        
		$success = false;
		$message = 'not login';
		$request = $this->getRequest();
		if($this->auth->hasIdentity()) {
			$user = $this->auth->getIdentity();
			$content = (array) json_decode($request->getContent());
			if(!isset($content["ID"]) || !isset($content["PASSWORD"])) {
				$message = 'Id / password tidak boleh kosong';
				$success = false;
			} else {
				$data = $this->lockAppStorage->read();
				if($user->ID != $content["ID"] || $data["ID"] != $content["ID"]) {
					$message = 'Id tidak valid';
					$success = false;
				} else {
					$datas = $this->penggunaService->load([
						"ID" => $content["ID"],
						'STATUS' => 1
					], ['JENIS', 'PASSWORD']);
					if(count($datas) == 0) {
						$message = 'Id tidak valid';
						$success = false;
					} else {
						if(Password::verify($datas[0]["PASSWORD"], $content["PASSWORD"])) {
							$data["LOCK"] = false;
							$this->lockAppStorage->write($data);
							$message = 'unlock';
							$success = true;
						} else {
							$message = 'Password tidak valid';
							$success = false;
						}
					}
				}
			}
		}
				
        return [
			'success' => $success,
			'message' => $message
		];
	}

	public function toLoginUserAction() 
	{
		$data = $this->lockAppStorage->read();
		$data["LOCK"] = false;
		$this->lockAppStorage->write($data);
		return $this->logoutAction();
	}
}