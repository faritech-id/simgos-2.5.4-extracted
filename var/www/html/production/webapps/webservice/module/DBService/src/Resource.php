<?php
namespace DBService;

use Laminas\ApiTools\Rest\AbstractResourceListener;
use Laminas\ApiTools\Rest\ResourceEvent;
use Laminas\ApiTools\ApiProblem\ApiProblem;

use SimpleXMLElement;

use Laminas\Json\Json;

use Laminas\Authentication\AuthenticationService;
use DBService\DatabaseService;
use Aplikasi\Signature;
use Aplikasi\Token;

use Aplikasi\V1\Rest\PenggunaAksesLog\Service as PenggunaAksesLog;
use Aplikasi\V1\Rest\Objek\Service as Objek;
use Aplikasi\db\bridge_log\Service as BridgeLogService;
use DBService\generator\Generator;
use Aplikasi\V1\Rest\PenggunaRequestLog\Service as PenggunaRequestLogService;
use Aplikasi\V1\Rest\Pengguna\PenggunaService;

use Laminas\Mail;
use Laminas\Mime\Message as MimeMessage;
use Laminas\Mime\Mime;
use Laminas\Mime\Part;

use Laminas\Authentication\Storage\Session as StorageSession;
use DBService\Crypto;

use Aplikasi\V1\Rest\PropertiConfig\Service as PropertyConfig;

class Resource extends AbstractResourceListener
{    
	const AUTH_TYPE_LOGIN = 0;
	const AUTH_TYPE_SIGNATURE = 1;
	const AUTH_TYPE_NOT_SECURE = 2;
	const AUTH_TYPE_SIGNATURE_OR_LOGIN = 3;
	const AUTH_TYPE_IP = 4;
	const AUTH_TYPE_IP_OR_LOGIN = 5;
	const AUTH_TYPE_IP_AND_LOGIN = 6;
	const AUTH_TYPE_SIGNATURE_OR_IP = 7;
	const AUTH_TYPE_SIGNATURE_AND_IP = 8;
	const AUTH_TYPE_TOKEN = 9;
	const AUTH_TYPE_LOGIN_OR_TOKEN = 10;
	const AUTH_TYPE_IP_OR_TOKEN = 11;
	
	const CONTENT_TYPE_JSON = 'json';
	
	protected $auth;
	protected $penggunaAksesLog;
	protected $penggunaRequestLog;
	protected $objek;
	protected $service;
	protected $privilages = [];
	protected $user;
	protected $serviceManager;
	protected $reponse;
	protected $request;
	protected $httpcode;
	protected $dataAkses;
	protected $integrasi = [];
	protected $crud = [
		"create" => "C",
		"read" => "R",
		"update" => "U",
		"delete" => "D"
	];
	protected $bridgeLog;
	protected $jenisBridge = 0;
	protected $moduleId = 0;
	protected $pengguna;
	
	private $signature = false;
	private $token = false;

	private $https = false;

	protected $disconnectAfterRequest = true;
	
	protected $authType = self::AUTH_TYPE_LOGIN;
	protected $authTypeAccess = -1;
	
	public static $maxRecursionDepthAllowed = 25;

	protected function onBeforeSendRequest() {}
	protected function onAfterSendRequest($curl, $result) {}

	protected function onBeforeAuthenticated($params = []) {}
	protected function onAfterAuthenticated($params = []) {}

	protected $title = "";
	protected $lockAppStorage;
	protected $allowIfLocking = false;
	protected $tokenStorage;
	protected $authGranted = false;

	protected $crypto;

	protected $responseHeaders = [];
	protected $error = null;
	
	public function __construct() {
		$this->auth = new AuthenticationService();
		$this->penggunaAksesLog = new PenggunaAksesLog();
		$this->penggunaRequestLog = new PenggunaRequestLogService();
		$this->pengguna = new PenggunaService();
		
		$this->bridgeLog = new BridgeLogService();
		$this->objek = new Objek();

		$this->lockAppStorage = new StorageSession("LOCKAPP", "STATUS");
		$this->tokenStorage = new StorageSession("AUTHENTICATION", "TOKEN");

		$this->crypto = new Crypto();
	}

	public function setServiceManager($serviceManager) {
		$this->serviceManager = $serviceManager;
		$this->response = $this->serviceManager->get("response");
		$this->request = $this->serviceManager->get("request");	

		$this->https = $this->request->getServer('REQUEST_SCHEME') == "https";
	}

	public function setDisconnectAfterRequest($val) {
		$this->disconnectAfterRequest = $val;
	}
	
	public function getSignature() {
		return $this->signature;
	}

	protected function writeBridgeLog($data=[]) {
		if(!isset($this->config["writeLog"])) return false;
		if(!$this->config["writeLog"]) return false;
		$isCreate = isset($data["ID"]) ? false : true;
		if($isCreate) $data["ID"] = Generator::generateIdBridgeLog();
		$data["JENIS"] = $this->jenisBridge;
		$this->bridgeLog->simpanData($data, $isCreate);
		return $data["ID"];
	}
    /**
     * Dispatch an incoming event to the appropriate method
     *
     * Marshals arguments from the event parameters.
     *
     * @param  ResourceEvent $event
     * @return mixed
     */
    public function dispatch(ResourceEvent $event)
    {
		$eventName = $event->getName();
		
		$oau = $this->onBeforeAuthenticated([
			"eventName" => $eventName,
			"event" => $event
		]);
		if($oau instanceof ApiProblem) return $oau;

		if($this->authType == self::AUTH_TYPE_LOGIN) {
			$result = $this->doAuthLogin();
			if(is_array($result)) return $result;
		} else if($this->authType == self::AUTH_TYPE_SIGNATURE) {
			$result = $this->doAuthSignature();
			if($result instanceof ApiProblem) return $result;
		} else if($this->authType == self::AUTH_TYPE_SIGNATURE_OR_LOGIN) {
			$result = $this->doAuthLogin();
			if(is_array($result)) {
				$result = $this->doAuthSignature();
				if($result instanceof ApiProblem) return $result;
			}
		} else if($this->authType == self::AUTH_TYPE_IP) {
			$result = $this->doAuthIP();
			if($result instanceof ApiProblem) return $result;
		} else if($this->authType == self::AUTH_TYPE_IP_OR_LOGIN) {
			$result = $this->doAuthIP();
			$resultLogin = $this->doAuthLogin();
			if(is_array($resultLogin)) {
				if($result instanceof ApiProblem) {
					$this->response->setStatusCode(405);
					$resultLogin["message"] .= " / ".$result->toArray()["detail"];
					return $resultLogin;
				}
			} else {
				$result = true;
			}
		    if($result instanceof ApiProblem) return $result;
		} else if($this->authType == self::AUTH_TYPE_IP_AND_LOGIN) {
		    $result = $this->doAuthIP();
		    if(!($result instanceof ApiProblem)) {
				$resultLogin = $this->doAuthLogin();
				if(is_array($resultLogin)) {
					$this->response->setStatusCode(405);
					//$e->setResult($result);
					$resultLogin["message"] .= " dan ".$result->toArray()["detail"];
					return $resultLogin;
				}		        
		    }
		    if($result instanceof ApiProblem) return $result;
		} else if($this->authType == self::AUTH_TYPE_SIGNATURE_OR_IP) {
		    $headers = $this->request->getHeaders();
		    if($headers->get("X-Signature")) {
		        $result = $this->doAuthSignature();
		    } else {
		        $result = $this->doAuthIP();
		    }
		    if($result instanceof ApiProblem) return $result;
		} else if($this->authType == self::AUTH_TYPE_SIGNATURE_AND_IP) {
		    $result = $this->doAuthSignature();
		    if(!($result instanceof ApiProblem)) {
		        $result = $this->doAuthIP();
		    }
		    if($result instanceof ApiProblem) return $result;
		} else if($this->authType == self::AUTH_TYPE_TOKEN) {
			$result = $this->doAuthToken();
			if($result instanceof ApiProblem) return $result;
		} else if($this->authType == self::AUTH_TYPE_LOGIN_OR_TOKEN) {
			$result = $this->doAuthLogin();
			if(is_array($result)) {
				$result = $this->doAuthToken();
				if($result instanceof ApiProblem) return $result;
			}
		} else if($this->authType == self::AUTH_TYPE_IP_OR_TOKEN) {
			$result = $this->doAuthIP();
		    if($result instanceof ApiProblem) {
		        $result = $this->doAuthToken();
				if($result instanceof ApiProblem) return $result;
		    }
			if($result instanceof ApiProblem) return $result;
		}

		$oau = $this->onAfterAuthenticated([
			"eventName" => $eventName,
			"event" => $event

		]);
		if($oau instanceof ApiProblem) return $oau;

		if(!$this->allowIfLocking) {
			$lockSession = $this->lockAppStorage->read();
			if($lockSession) {
				if($lockSession["LOCK"]) return new ApiProblem(401, "Akses API terkunci, silahkan buka kuncinya terlebih dahulu");
			}
		}

		$result = $this->validateAuthorization();
		if($result instanceof ApiProblem) return $result;

		$idLogPenggunaRequest = $this->writeLogPenggunaRequest();
				
		$id = $event->getParam('id', null);
        $data = (array) $event->getParam('data', []);		
		$dataBeforeUpdate = [];
		$dataBefore = [];
		$deleteData = [];
		$keys = [];
		$service = $this->service instanceof Service ? $this->service : null;
		$entity = null;
		if($service) {
			$entity = $service->getEntity();
			if($entity) $keys = $entity->getIdKeys();
		}

		if($this->isCUD($event)) {
			if($eventName == "create" || $eventName == "update") {
				$data = $this->decryptData($data);
				if($this->authGranted) $event->setParam("data", (object) $data);
			}
		}
		
		if(count($keys) == 0) {
			$dispatch =  parent::dispatch($event);
			$this->finishLogPenggunaRequest($idLogPenggunaRequest);
			if($this->disconnectAfterRequest) if($service) $service->disconnect();
			if(isset($dispatch["data"])) $dispatch["data"] = $this->encryptData($dispatch["data"]);
			if(isset($dispatch["children"])) $dispatch["children"] = $this->encryptData($dispatch["children"]);
			return $dispatch;
		}
		
		if($this->isWriteLog()) {
			if($this->isCUD($event)) {
				/* load data sebelum di cud */
				if($eventName == "update" || $eventName == "delete") {
					$result = $service->load([
						$keys[0] => $id
					]);
					
					if(count($result) > 0) {
						if($eventName == "update") {
							$data = $this->decryptData($data);
							foreach($data as $key => $val) {
								if(isset($result[0][$key])) {							
									if($result[0][$key] != $val) {
										$dataBeforeUpdate[$key] = $result[0][$key];
									} else {
										$deleteData[$key] = $val;
									}
								}
							}
							
							if(isset($dataBeforeUpdate["OLEH"])) unset($dataBeforeUpdate["OLEH"]);
							if(isset($dataBeforeUpdate[$keys[0]])) unset($dataBeforeUpdate[$keys[0]]);
						}
						$dataBefore = $result[0];
					}
				}
			}
		}
		
        $return = parent::dispatch($event);
		if(!isset($return)) {
			$this->finishLogPenggunaRequest($idLogPenggunaRequest);
			if($this->disconnectAfterRequest) if($service) $service->disconnect();
			return $return;
		}
		if($return instanceof ApiProblem) {
			$this->finishLogPenggunaRequest($idLogPenggunaRequest);
			if($this->disconnectAfterRequest) if($service) $service->disconnect();
			return $return;
		}
		
		if($this->isWriteLog()) {
			if($this->isCUD($event)) {
				$tipe = $this->crud[$eventName];
				$usrId = $this->user;
				$tableIdentifier = $service->getTable()->getTable();
				$table = is_object($tableIdentifier) ? $tableIdentifier->getTable() : $tableIdentifier;
				$schema = is_object($tableIdentifier) ? ($tableIdentifier->hasSchema() ? $tableIdentifier->getSchema() : "") : "";
				$objek = $schema == "" ? $table : $schema.".".$table;
				$ref = $id;
				$sebelum = $sesudah = "";
				$dt = null;
				
				/* get key value after insert */
				if($eventName == "create") {
					if(isset($return["success"])) {
						if($return["success"]) {
							if(isset($return["data"])) {
								$dt = $return["data"];								
								if(is_array($dt)) {
									if(count($dt) > 0) {
										if(!isset($dt[$keys[0]])) {
											if(isset($dt[0])) {
												if(is_string($dt[0]) || is_integer($dt[0])) $dt = $dt[0];												
											}
										}
									}
								} 
								if($dt) {
									if(isset($dt["success"])) $dt = null;
								}
							}
						}
					} else {
						if(is_array($return)) {
							if(count($return) > 0) {
								$dt = [$return];
								if(isset($return[0])) $dt = $return[0];
							}
						} else {
							if(is_string($return) || is_integer($return)) $ref = $return;
							else {
								$this->finishLogPenggunaRequest($idLogPenggunaRequest);
								if($this->disconnectAfterRequest) if($service) $service->disconnect();
								if(isset($return["data"])) $return["data"] = $this->encryptData($return["data"]);
								if(isset($return["children"])) $return["children"] = $this->encryptData($return["children"]);
								return $return;
							}
						}
					}
					
					if($dt) {
						if(!isset($dt[$keys[0]])) {
							if(count($dt) > 0) {
								$dt = $dt[0];
								if(!isset($dt[$keys[0]])) {
									$this->finishLogPenggunaRequest($idLogPenggunaRequest);
									if($this->disconnectAfterRequest) if($service) $service->disconnect();
									if(isset($return["data"])) $return["data"] = $this->encryptData($return["data"]);
									if(isset($return["children"])) $return["children"] = $this->encryptData($return["children"]);
									return $return;
								}
							}
						}
						$ref = $dt[$keys[0]];		
						
						if($ref == "" || $ref == null) {
							try {
								$ref = $service->getTable()->getLastInsertValue();
								if($ref == 0) {
									$this->finishLogPenggunaRequest($idLogPenggunaRequest);
									if($this->disconnectAfterRequest) if($service) $service->disconnect();
									if(isset($return["data"])) $return["data"] = $this->encryptData($return["data"]);
									if(isset($return["children"])) $return["children"] = $this->encryptData($return["children"]);
									return $return;
								}
							} catch(\Exception $e) {
								$this->finishLogPenggunaRequest($idLogPenggunaRequest);
								if($this->disconnectAfterRequest) if($service) $service->disconnect();
								if(isset($return["data"])) $return["data"] = $this->encryptData($return["data"]);
								if(isset($return["children"])) $return["children"] = $this->encryptData($return["children"]);
								return $return;
							}
						}
					} else {
						$this->finishLogPenggunaRequest($idLogPenggunaRequest);
						if($this->disconnectAfterRequest) if($service) $service->disconnect();
						if(isset($return["data"])) $return["data"] = $this->encryptData($return["data"]);
						if(isset($return["children"])) $return["children"] = $this->encryptData($return["children"]);
						
						return $return;
					}
				}
				
				if($eventName == "update") {
					if(isset($data["OLEH"])) unset($data["OLEH"]);
					if(isset($data[$keys[0]])) unset($data[$keys[0]]);
					foreach($deleteData as $key => $val) {
						if(isset($data[$key])) unset($data[$key]);
					}
					$sebelum = count($dataBeforeUpdate) > 0 ? $dataBeforeUpdate : null;
					$sesudah = $data;
					$sesudah = count($sesudah) > 0 ? $sesudah : null;
				}
				
				if($eventName == "delete") {
					$sebelum = count($dataBefore) > 0 ? $dataBefore : null;
				}
				
				$ref = is_object($ref) || is_array($ref) ? json_encode($ref) : $ref;
				$sebelum = is_object($sebelum) || is_array($sebelum) ? json_encode($sebelum) : $sebelum;
				$sesudah = is_object($sesudah) || is_array($sesudah) ? json_encode($sesudah) : $sesudah;							
				
				$obj = [
					"TABEL" => $objek
				];
				$findObject = $this->objek->load($obj);
				if(count($findObject) > 0) {
					if($findObject[0]["ENTITY"] == '' || $findObject[0]["SERVICE"] == '') {
						$findObject[0]["ENTITY"] = get_class($entity);
						$findObject[0]["SERVICE"] = get_class($service);
						$this->objek->simpan($findObject[0], false, false);
					}
					
					if(!empty($sesudah) || $tipe == "C") {
						$this->penggunaAksesLog->simpan([
							"TANGGAL" => new \Laminas\Db\Sql\Expression("NOW()"),
							"PENGGUNA" => $usrId,
							"AKSI" => $tipe,
							"OBJEK" => $findObject[0]["ID"],
							"REF" => $ref,
							"SEBELUM" => $sebelum ? $sebelum : "",
							"SESUDAH" => $sesudah
						], true, false);
					}
				}
			}
		}
		
		$this->finishLogPenggunaRequest($idLogPenggunaRequest);
		if($this->disconnectAfterRequest) if($service) $service->disconnect();
		if(isset($return["data"])) $return["data"] = $this->encryptData($return["data"]);		
		if(isset($return["children"])) $return["children"] = $this->encryptData($return["children"]);
		return $return;
    }

	private function validateAuthorization() {
		if($this->https) {
			if($this->authType == self::AUTH_TYPE_LOGIN || $this->authTypeAccess == self::AUTH_TYPE_LOGIN) {
				$headers = $this->request->getHeaders();
				$authHeader = $headers->get("Authorization");
				if(!$authHeader) return new ApiProblem(428, "Token Required");
				$token = trim(str_replace("Bearer ", "", $authHeader->getFieldValue()));
				if($token == "") return new ApiProblem(428, "Token Required");
				$key = $this->tokenStorage->read();
				if($key) {
					$key = (array) $key;
					if($token != $key["TOKEN"]) return new ApiProblem(401, "Invalid Token");
					// coming check timeout
					$this->authGranted = true;
					return true;
				} return new ApiProblem(428, "Token Required");
			}
		}

		return true;
	}
	private function encryptData($data) {
		if($this->authGranted) {
			$key = $this->tokenStorage->read();
			if($key) {
				$key = (array) $key;
				$this->crypto->setKey($key["TOKEN"]);
				$content = (json_encode($data));
				$data = $this->crypto->encrypt($content, true, true);
			}
		}

		return $data;
	}

	private function decryptData($data) {
		if($this->authGranted) {
			$key = $this->tokenStorage->read();
			if($key) {
				$key = (array) $key;
				$this->crypto->setKey($key["TOKEN"]);
				if(isset($data["data"])) {
					$data = $this->crypto->decrypt($data["data"], true, true);
					if($data) $data = (array) json_decode($data, true);
				}
			}
		}

		return $data;
	}
	
	private function isCUD($event) {
		$name = $event->getName();
		return $name == "create" || $name == "update" || $name == "delete"; 
	}
	
	private function isWriteLog() {
		if($this->service) {
			if($this->service instanceof Service) return $this->service->isWriteLog();
			else return false;
		} else return false;
	}	

	private function writeLogPenggunaRequest() {
		$id = null;
		if(!isset($this->request)) return;
		$allow = $this->getPropertyConfig(51);
		if($allow) {
			if($allow == "TRUE" && $this->authTypeAccess == self::AUTH_TYPE_LOGIN) {
				$forwardHost = $this->request->getServer('HTTP_X_FORWARDED_FOR');
				$location = $forwardHost ? $forwardHost : $this->request->getServer('REMOTE_ADDR');
				$uri = $this->request->getServer('REQUEST_URI');
				$server = $this->request->getServer('SERVER_ADDR');
				$id = $this->penggunaRequestLog->simpanData([
					"PENGGUNA" => $this->user,
					"TANGGAL_AKSES" => new \Laminas\Db\Sql\Expression('NOW()'),
					"LOKASI_AKSES" => $location,
					"TUJUAN_AKSES" => $server,
					"REQUEST_URI" => $uri
				], true, false);
			}
		}

		return $id;
	}

	private function finishLogPenggunaRequest($id) {
		if($id) {
			$this->penggunaRequestLog->simpanData([
				"ID" => $id,
				"TANGGAL_SELESAI" => new \Laminas\Db\Sql\Expression('NOW()')
			], false, false);
		}
	}
	
	private function doAuthLogin() {
		if(!$this->auth->hasIdentity()) {
			return [
				'success' => false,
				'message' => 'not login',
				'data' => null
			];
		}

		$data = $this->auth->getIdentity();
		$this->privilages = (array) $data->XPRIV;
		if(isset($data->XITR)) $this->integrasi = $data->XITR;
		$this->user = $data->ID;
		$this->dataAkses = $data;
		$this->authTypeAccess = self::AUTH_TYPE_LOGIN;	
		return true;
	}
	
	private function doAuthSignature() {
		if(!isset($this->request)) {
			return new ApiProblem(500, 'Error Script: request is null');
		}
		
		$headers = $this->request->getHeaders();					
		$this->signature = new Signature(
			$headers->get("X-Id"),
			$headers->get("X-Timestamp"),
			$headers->get("X-Signature")
		);
		
		try {
			$this->signature->isValidSignature();
			$this->authTypeAccess = self::AUTH_TYPE_SIGNATURE;
		} catch(\Exception $e) {
			return new ApiProblem($e->getCode(), $e->getMessage());
		}
	}

	private function doAuthToken() {
		if(!isset($this->request)) {
			return new ApiProblem(500, 'Error Script: Request is null');
		}

		$headers = $this->request->getHeaders();		
		$this->token = new Token(
			$headers->get("X-Token")
		);
		
		try {
			$this->token->isValidToken();
			$this->authTypeAccess = self::AUTH_TYPE_TOKEN;
		} catch(\Exception $e) {
			return new ApiProblem($e->getCode(), $e->getMessage());
		}
	}
	
	private function doAuthIP() {
		if(!isset($this->request)) {
			return new ApiProblem(500, 'Error Script: request is null');
		}
		
		$ip = $this->request->getServer('REMOTE_ADDR');
		
		$db = DatabaseService::get("SIMpel");
		$adapter = $db->getAdapter();
		
		$stmt = $adapter->query('
			SELECT *
			  FROM aplikasi.allow_ip_authentication
			 WHERE NOMOR = ?');
		$results = $stmt->execute([$ip]);
		$result = $results->current();
		$allow = false;
		if($result) $allow = $result["STATUS"] == 1;
		if(!$allow) {
			return new ApiProblem(401, "IP $ip is not allowed / registered");
		} else {
			$this->authTypeAccess = self::AUTH_TYPE_IP;
		}
		
		return true;
	}
	
	/*
		Examples:
		array(
			'123' => '123'
		);
	*/
	public function isAllowPrivilage($id) {
		$allow = false;
		foreach($this->privilages as $key=>$val) {
			if($key == $id) {
				$allow = true;
				break;
			}
		}
		return $allow;
	}
	
	/*
		Examples:
		array(
			'0' => array(
				'ID' => '1'
			)
		);
	*/
	public function isIntegrasi($field, $val) {
		$allow = false;
		foreach($this->integrasi as $data) {
			$data = (array) $data;
			if($data[$field] == $val) {
				$allow = true;
				break;
			}
		}
		return $allow;
	}
	
	public function toResponse($data = []) {
		if($this->request->getHeaders()->get("accept")->getFieldValue() == "application/json") return $this->toJson($data);
		return $this->toXML($data);
	}
	
	public function toJson($data = []) {
		$json = json_encode($data);
		//$json = str_replace("]", "", str_replace("[", "", $json));		
		$this->response->setContent($json);
		$headers = $this->response->getHeaders();
		$headers->clearHeaders()
			->addHeaderLine('Content-Type', 'application/json')
			->addHeaderLine('Content-Length', strlen($json));
        
		return  $this->response;
	}
	
	public function toXML($data = []) {
		$doc = new SimpleXMLElement("<xml version='1.0'></xml>");
		foreach($data as $entity) {
			$dt = $doc->addChild("data");
			foreach($entity as $key => $val) {
				$dt->addChild($key, htmlspecialchars($val));
			}
		}
		$xmlString = $doc->asXML();
		$xmlString = str_replace(['<?xml version="1.0"?>', "\n", "\r"], "", $xmlString);
		$this->response->setContent($xmlString);
		$headers = $this->response->getHeaders();
		$headers->clearHeaders()
			->addHeaderLine('Content-Type', 'application/xml')
			->addHeaderLine('Content-Length', strlen($xmlString));
        
		return  $this->response;
	}
	
	public function downloadDocument($content, $tipe, $ext, $id, $attachment = true) {
		$this->response->setContent($content);
		$headers = $this->response->getHeaders();
		$filename = $id.".".$ext;
		$headers->clearHeaders()
			->addHeaderLine('Content-Type', $tipe)
			->addHeaderLine('Content-Length', strlen($content));
			
		if($attachment) $headers->addHeaderLine('Content-Disposition', 'attachment; filename="'.$filename.'"');
        
		return $this->response;
	}
	
	protected function getXMLPostData() {
		if(!isset($this->request)) {
			return new ApiProblem(500, 'Error Script: request is null');
		}
						
        return new SimpleXMLElement($this->request->getContent());
	}
			
	/*
	 * array(
	 *		url => "Uniform Resource Locator",
	 *		action => "Web Service Name",
	 *		method => "{GET|POST|PUT|DELETE}",
	 *		data => "JSON String",
	 *      dataIsJson => true,
	 *		header => [],
	 *      json_encode_return => true
	 * )
	*/
	public function sendRequest($options = []) {
		$curl = curl_init();
		
		$rHeaders = [];

		$jsonEncodeReturn = isset($options["json_encode_return"]) ? $options["json_encode_return"] : true;
		$action = isset($options["action"]) ? (trim($options["action"]) != "" ? "/".$options["action"] : "") : "";				
		
		// default true
		$options["dataIsJson"] = !isset($options["dataIsJson"]) ? true : $options["dataIsJson"];
		$data = "";
		if(isset($options["data"])) {
			if($options["dataIsJson"]) {
				if(is_string($options["data"])) $data = $options["data"];
				else $data = json_encode($options["data"]);
			} else {
				$data = $options["data"];
			}
		}
		
		$this->onBeforeSendRequest();

		if(!isset($this->headers)) {
			$headers = [
				"Content-type: application/json",
				"Content-length: ".strlen($data)
			];
		} else {
			$headers = $this->headers;
		}
		if(isset($options["header"])) {
			foreach($options["header"] as $header) {
				if(!is_bool(strpos($header, "Content-type"))) unset($headers[0]);
			}
			$headers = array_merge($headers, $options["header"]);
		}
		
		$id = $this->writeBridgeLog([
			"URL" => $options["url"].$action,
			"HEADERS" => json_encode($headers),
			"REQUEST" => $data,
			"HTTP_METHOD" => (isset($options["method"]) ? $options["method"] : "GET"),
			"ACCESS_FROM_IP" => $_SERVER['REMOTE_ADDR']
		]);
		
		curl_setopt($curl, CURLOPT_URL, $options["url"].$action);
		curl_setopt($curl, CURLOPT_HEADER, false);
		curl_setopt($curl, CURLOPT_CUSTOMREQUEST, isset($options["method"]) ? $options["method"] : "GET");
		curl_setopt($curl, CURLOPT_POSTFIELDS, $data);		
		
		curl_setopt($curl, CURLOPT_FOLLOWLOCATION, true); 
		curl_setopt($curl, CURLOPT_RETURNTRANSFER, true); 
		curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, false); 
		curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false); 
		curl_setopt($curl, CURLOPT_HTTPHEADER, $headers);
		curl_setopt($curl, CURLOPT_HEADERFUNCTION, function($curl, $head) use (&$rHeaders)
        {
          $len = strlen($head);
          $head = explode(':', $head, 2);
          if (count($head) < 2) // ignore invalid headers
            return $len;
      
          $rHeaders[strtolower(trim($head[0]))] = trim($head[1]);
      
          return $len;
        });
		$timeout = isset($options["timeout"]) ? $options["timeout"] : (isset($this->config["timeout"]) ? $this->config["timeout"] : 10);
		curl_setopt($curl, CURLOPT_CONNECTTIMEOUT, $timeout);
		curl_setopt($curl, CURLOPT_TIMEOUT, $timeout);
		
		$result = curl_exec($curl);
		$err = curl_error($curl);

		$this->httpcode = curl_getinfo($curl, CURLINFO_HTTP_CODE);
		$this->responseHeaders = $rHeaders;
		$this->onAfterSendRequest($curl, $result);
		curl_close($curl);

		if($err) $this->error = $err;

		$this->writeBridgeLog([
			"ID" => $id,
			"RESPONSE" => $result,
			"HTTP_STATUS_CODE" => $this->httpcode
		]);
			
		return $jsonEncodeReturn ? json_decode($result) : $result;
	}
	
	protected function getPostData() {
		$request = $this->request;
		if ($this->requestHasContentType($request, self::CONTENT_TYPE_JSON)) {
			$data = Json::decode($request->getContent(), $this->jsonDecodeType);
        } else {
            $data = $request->getPost()->toArray();
        }
		
		return $data;
	}
	
	/* Send Mail */
	/*
	 * [
	 * 		"display_name" => "Nama Display Email",
	 *		"from" => "Email Asal",
	 *		"to" => "Email Tujuan",
	 *		"subject" => "Subject Email",
	 *		"body" => "content or mime message (text dan attachment)"	 
	 * ]
	 * example:
	 * [
	 * 		"from" => "admin@simpel.web.id",
	 * 		"to" => "somebody@email.com",
	 * 		"subject" => "Kirim Email",
	 * 		// "body" => "Dear Email" atau
	 * 		"body => [
	 * 			[ // gunakan parameter option ini bisa menggunakan class Part using use Laminas\Mime\Part;
	 * 				"content" => "text or content file (stream)",
	 * 				"type" => Mime::TYPE_HTML, // using use Laminas\Mime\Mime;
	 * 				"charset" => "utf-8", // optional
	 * 				"filename" => "Nama File",
	 * 				"disposition" => Mime::DISPOSITION_ATTACHMENT, // using Laminas\Mime\Mime
	 * 				"encoding" => Mime::ENCODING_BASE64 // using Laminas\Mime\Mime
	 * 			] // ini bisa lebih dari satu array
	 * 		]
	 * ]
	*/
	protected function sendMail($options = []) {
		$mail = new Mail\Message();
		$config = $this->config["services"]["MailServer"];
		$body = isset($options["body"]) ? $options["body"] : "";
		$headerType = "multipart/alternative";
		$contents = [];
		//set_time_limit($config["max_timeout"]);
		
		if(is_array($body)) {
			foreach($body as $b) {
				if($b instanceof Part) {
					$contents[] = $b;
					
					if($b->disposition == Mime::DISPOSITION_ATTACHMENT) $headerType = "multipart/related";
				} else {
					if(isset($b["content"])) {
						$part = new Part($b["content"]);
						if(isset($b["type"])) $part->type = $b["type"];
						if(isset($b["charset"])) $part->charset = $b["charset"];
						if(isset($b["filename"])) $part->filename = $b["filename"];
						if(isset($b["disposition"])) {
							$part->disposition = $b["disposition"];
							if($b["disposition"] == Mime::DISPOSITION_ATTACHMENT) {
								//file_put_contents("logs/payroll.pdf", $b["content"]);
								$headerType = "multipart/related";
							}
						}
						if(isset($b["encoding"])) $part->encoding = $b["encoding"];
						$contents[] = $part;				
					} 
				}
			}
		}

		if(is_string($body) || count($contents) == 0) {
			$part = new Part($body);
			$part->type = Mime::TYPE_HTML;
			$part->charset = 'utf-8';
			$part->encoding = Mime::ENCODING_QUOTEDPRINTABLE;
			$contents[] = $part;
		}
		
		$bodyMessage = new MimeMessage();
		$bodyMessage->setParts($contents);

		$mail->setEncoding("UTF-8");
	    $mail->setBody($bodyMessage)
	    	->setFrom(
				isset($options["from"]) ? $options["from"] : $config["connection_config"]["username"],
				isset($options["display_name"]) ? $options["display_name"] : $config["connection_config"]["display_name"]
			)
			->addTo($options["to"])
			->setSubject($options["subject"]);
			
		$contentTypeHeader = $mail->getHeaders()->get('Content-Type');
		if(count($contents) > 1) $contentTypeHeader->setType($headerType);
	    
	    $smtpOption = new Mail\Transport\SmtpOptions($config);	    
	    $transport = new Mail\Transport\Smtp($smtpOption);		
	    try {
			$transport->send($mail);			
			return true;
	    } catch(\Exception $e) {			
	        return new ApiProblem(500, 'Error: '.($e->getMessage()));
	    }
	}

	/**
     * Create a resource
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function create($data)
    {
        $result = [
			"status" => 422,
			"success" => false,
			"detail" => "Gagal menyimpan ".$this->title
        ];

		$notValidEntity = $this->service->getEntity()->getNotValidEntity($data, false);
        if(count($notValidEntity) > 0) {
			$result["status"] = 412;
            $result["detail"] = $notValidEntity["messages"];
			return new ApiProblem($result["status"], $result["detail"], null, null, ["success" => false]); 
        }
		
        $result["data"] = null;
		$data = is_array($data) ? $data : (array) $data;
        $data["OLEH"] = $this->user;
		
		$success = $this->service->simpanData($data, true);
		if($success) {
			$result["status"] = 200;
			$result["success"] = true;
			$result["data"] = $success[0];
			$result["detail"] = "Berhasil menyimpan ".$this->title;
		}
		
		if(!$result["success"]) return new ApiProblem($result["status"], $result["detail"], null, null, ["success" => false]); 
		
		return $result;
	}
	
	/**
     * Fetch a resource
     *
     * @param  mixed $id
     * @return ApiProblem|mixed
     */
    public function fetch($id)
    {
		$entityId = $this->service->getEntityId();
        $params = [$entityId => $id];
        $data = $this->service->load($params);
		
		$result = [
			"status" => count($data) > 0 ? 200 : 404,
			"success" => count($data) > 0 ? true : false,
			"total" => count($data),
			"data" => count($data) ? $data[0] : null,
			"detail" => $this->title.(count($data) > 0 ? " ditemukan" : " tidak ditemukan")
        ];
		
		return $result;
	}
	
	/**
     * Fetch all or a subset of resources
     *
     * @param  array $params
     * @return ApiProblem|mixed
     */
    public function fetchAll($params = [])
    {
		if(isset($params['REFERENSI'])) {
			$this->service->setReferences((array) json_decode($params['REFERENSI']), true);
			unset($params['REFERENSI']);
		}
		
		if(isset($params['COLUMNS'])) {	
			$this->service->setColumns((array) json_decode($params['COLUMNS']));
			unset($params['COLUMNS']);
		}
		
        return new ApiProblem(405, 'The GET method has not been defined for collections');
	}
	
	protected function isValidateBeforeUpdate($id, $data, $records) {
		return true;
	}
	/**
     * Update a resource
     *
     * @param  mixed $id
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function update($id, $data)
    {
        $result = [
			"status" => 422,
			"success" => false,
			"data" => null,
			"detail" => "Gagal merubah data ".$this->title
		];
		
		$notValidEntity = $this->service->getEntity()->getNotValidEntity($data, false, "PUT");
        if(count($notValidEntity) > 0) {
			$result["status"] = 412;
            $result["detail"] = $notValidEntity["messages"];
			return new ApiProblem($result["status"], $result["detail"], null, null, ["success" => false]); 
        }

		$entityId = $this->service->getEntityId();
		$data = is_array($data) ? $data : (array) $data;
		$data[$entityId] = $id;
		$data["OLEH"] = $this->user;
		$params = [$entityId => $id];
		
		$records = $this->service->load($params);
		$canUpdate = count($records) > 0;

		$valid = $this->isValidateBeforeUpdate($id, $data, $records);
		if($valid instanceof ApiProblem) return $valid;
		
		if($canUpdate) {
			$success = $this->service->simpanData($data);
			if($success) {
				$result["status"] = 200;
				$result["success"] = true;
				$result["data"] = $success[0];
				$result["detail"] = "Berhasil merubah data ".$this->title;
			}
		}
		
		if(!$result["success"]) return new ApiProblem($result["status"], $result["detail"], null, null, ["success" => false]); 
		
		return $result;
    }

	public function getPropertyConfig($id, $type = "string") {
		$result = null;
		if($this->dataAkses) {
			foreach($this->dataAkses->PC as $dt) {
				if($dt->ID == $id) {
					$result = $dt->VALUE;
					$val = str_replace("\r\n", "", $dt->VALUE);
					if($type == "json") $result = json_decode($val, true);
					if($type == "int") $result = intval($val);
					if($type == "bool") $result = ($val == "TRUE");
					break;
				}
			}
		}

		if($result == null) {
			$pc = new PropertyConfig();
			$founds = $pc->load([
				"ID" => $id
			]);
			if(count($founds) > 0) {
				$result = $founds[0]["VALUE"];
				$val = str_replace("\r\n", "", $founds[0]["VALUE"]);
				if($type == "json") $result = json_decode($val, true);
				if($type == "int") $result = intval($val);
				if($type == "bool") $result = ($val == "TRUE");
			}
			unset($pc);
		}

		return $result;
	}

	public function getPengguna() {
		return $this->pengguna;
	}

	public function getPeriodeAkhirSoRuangan($ruangan) {
		$db = DatabaseService::get("SIMpel");
		$adapter = $db->getAdapter();
		$stmt = $adapter->query('SELECT inventory.getPeriodeAkhirSo(?) AS PERIODE');
		$results = $stmt->execute(array($ruangan));
		$result = $results->current();
		if($result) return $result["PERIODE"];
		return "2000-01-01 00:00:01";
	}

	public function getHttpCode() {
		return $this->httpcode;
	}
	public function getError() {
		return $this->error;
	}
	public function getResponseHeaders() {
		return $this->responseHeaders;
	}
}
