<?php
namespace DocumentStorage\V1\Rpc\Document;

use DBService\RPCResource;
use DBService\Crypto;
use DBService\generator\Generator;
use Laminas\ApiTools\ApiProblem\ApiProblem;
use DocumentStorage\SFTPConnection;
use Laminas\Authentication\Storage\Session as StorageSession;
use DBService\System;

class DocumentController extends RPCResource
{
    protected $title = "Document Storage";
    private $crypto;
    private $sftp;

    public function __construct($controller) {
        $this->authType = self::AUTH_TYPE_IP_OR_LOGIN;

        $this->config = $controller->get('Config');
        $this->config = $this->config['services']['DokumentStorage'];

        $this->crypto = new Crypto();
        $this->service = new Service();

        $this->storageSession = new StorageSession("DS", "RA");
        $this->useHttps = true;
        $this->initConstruct();
    }

    protected function onAfterAuthenticated($params = []) {
        if(empty($this->config)) return new ApiProblem(412, "Konfigurasi Document Storage belum di setting di local.php");
        $default = ini_get('default_socket_timeout');
        try {
            if(isset($this->config["timeoutConnection"])) {
                if($this->config["timeoutConnection"] > 0) ini_set('default_socket_timeout', $this->config["timeoutConnection"]);
            }
            $this->sftp = new SFTPConnection($this->config["host"], $this->config["port"]);
        } catch(\Exception $e) {
            return new ApiProblem(412, "Gagal tehubung ke Layanan Penyimpanan Dokumen");
        } finally {
            ini_set('default_socket_timeout', $default);
        }
        $event = $params["event"];
        $routeMatch = $event->getRouteMatch();
        $action = $routeMatch->getParam('action', false);
        if($action == "download") $this->useHttps = false;
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

        $data = is_object($data) ? (array) $data : $data;
		
        if($this->user == null) $this->service->getEntity()->setRequiredFields(true, ["CREATED_BY"]);
        if(isset($data["FILE_LOCATION"])) $this->service->getEntity()->setRequiredFields(false, ["DATA"]);

		$notValidEntity = $this->service->getEntity()->getNotValidEntity($data, false);
        if(count($notValidEntity) > 0) {
			$result["status"] = 412;
            $result["detail"] = $notValidEntity["messages"];
			$this->response->setStatusCode($result["status"]);
			return $result;
        }

        if(isset($data["FILE_LOCATION"])) {
            $data["DATA"] = file_get_contents($data["FILE_LOCATION"]);
            unset($data["FILE_LOCATION"]);
        }

        $dataTmp = $this->service->getFileContentFromPost($data["DATA"], ['application/pdf', 'image/jpeg', 'image/png'], "Salah upload file dokumen, file yang di izinkan adalah format pdf/jpg/png");
        if($dataTmp instanceof ApiProblem) {
            $errors = $dataTmp->toArray();
            $this->response->setStatusCode($errors["status"]);
            return $errors;
        }

        $data["CONTENT_TYPE"] = $dataTmp["tipe"];
        $data["DATA"] = base64_encode($dataTmp["content"]);

        $result["data"] = null;
        $created = true;

        $params = [
            "DOCUMENT_DIRECTORY_ID" => $data["DOCUMENT_DIRECTORY_ID"],
            "REFERENCE_ID" => $data["REFERENCE_ID"]
        ];
        if(!empty($data["REVISION_FROM"])) $params["REVISION_FROM"] = $data["REVISION_FROM"];
        $finds = $this->service->load($params);

        if(count($finds) > 0) {
            $tgls = explode(" ",  $finds[0]["CREATED_DATE"]);
            $adapter = $this->service->getTable()->getAdapter();
            $now = System::getSysDate($adapter, false, true);
            if($now == $tgls[0]) {
                $created = false;
                $data["ID"] = $finds[0]["ID"];
                $data["UPDATED_DATE"] = new \Laminas\Db\Sql\Expression('NOW()');
                if($this->user) $data["UPDATED_BY"] = $this->dataAkses->NAME;
                else {
                    if(!empty($data["CREATED_BY"])) {
                        $data["UPDATED_BY"] = $data["CREATED_BY"];
                        unset($data["CREATED_BY"]);
                    }
                }
            }
        }
        
        if($created) {
            $data["ID"] = Generator::generateUUID();
            $data["CREATED_DATE"] = new \Laminas\Db\Sql\Expression('NOW()');
            if($this->user) $data["CREATED_BY"] = $this->dataAkses->NAME;
        }
        
        $ids = explode("-", $data["ID"]);
        $data["LOCATION"] = $this->config["location"];
        $data["KEY"] = $this->crypto->generateKey($ids[0]);
        $content = $data["DATA"];
        unset($data["DATA"]);
		
		$success = $this->service->simpanData($data, $created);
		if($success) {
			$result["status"] = 200;
			$result["success"] = true;
			$result["data"] = $success[0];
			$result["detail"] = "Berhasil menyimpan ".$this->title;
           
            $dokDir = "";
            if(!empty($result["data"]["REFERENSI"])) {
                if(!empty($result["data"]["REFERENSI"]["DOCUMENT_DIRECTORY"])) $dokDir = $result["data"]["REFERENSI"]["DOCUMENT_DIRECTORY"]["DIRECTORY"]."/";
            }
            $dokDir = str_replace("-", "", $dokDir);
            $content = $this->crypto->encrypt($content);
            try {
                $this->sftp->login($this->config["username"], $this->config["password"]);
            } catch(\Exception $e) {
                $this->response->setStatusCode(412);
                return (new ApiProblem(412, "Kesalahan authentikasi ke Layanan Penyimpanan Dokumen"))->toArray();
            }
            $data["ID"] = str_replace("-", "", $data["ID"]);
            $tgls = explode(" ", $result["data"]["CREATED_DATE"]);
            $tgls = explode("-", $tgls[0]);
            $file = $data["LOCATION"]."/".$dokDir.$tgls[0]."/".$tgls[1]."/".$tgls[2]."/".$data["ID"];
            $this->sftp->createDirectory($data["LOCATION"]);
            if($dokDir != "") {
                $this->sftp->createDirectory($data["LOCATION"]."/".$dokDir);
                $this->sftp->createDirectory($data["LOCATION"]."/".$dokDir.$tgls[0]);
                $this->sftp->createDirectory($data["LOCATION"]."/".$dokDir.$tgls[0]."/".$tgls[1]);
                $this->sftp->createDirectory($data["LOCATION"]."/".$dokDir.$tgls[0]."/".$tgls[1]."/".$tgls[2]);
            }
            try {
                $this->sftp->uploadStreamData($content, $file);
            } catch(\Exception $e) {
                $this->response->setStatusCode(412);
                return (new ApiProblem(412, "Gagal pengiriman dokumen ke Layanan Penyimpanan Dokumen"))->toArray();
            }
            $this->sftp->disconnect();
            unset($result["data"]["LOCATION"]);
            unset($result["data"]["KEY"]);
            if(!empty($result["data"]["REFERENSI"])) {
                if(!empty($result["data"]["REFERENSI"]["DOCUMENT_DIRECTORY"])) unset($result["data"]["REFERENSI"]["DOCUMENT_DIRECTORY"]["DIRECTORY"]);
            }
		}
		
		$this->response->setStatusCode($result["status"]);		
		return $result;
	}

    public function downloadAction() {
        $params = (array) $this->request->getQuery();

        if(empty($params["requestAccessNumber"])) {
            $this->response->setStatusCode(422);
            return [
                "status" => 422,
                "success" => false,
                "detail" => "Parameter requestAccessNumber harus di isi"
            ];
        }

        $result = [
			"status" => 422,
			"success" => false,
			"detail" => "Gagal mengambil dokumen"
        ];

        $downloadFile = false;
        if(isset($params["DOWNLOAD_FILE"])) $downloadFile = $params["DOWNLOAD_FILE"] = 1;

        $data = $this->storageSession->read();
        $this->storageSession->write([]);
        if($data) {
            $this->crypto->setKey($params["requestAccessNumber"]);
            $data = $this->crypto->decrypt($data);
            $data = base64_decode($data);
            $data = (array) json_decode($data);
            $dokDir = "";
            if(!empty($data["REFERENSI"])) {
                $ref = (array) $data["REFERENSI"];
                $dok = (array) $ref["DOCUMENT_DIRECTORY"];
                if(!empty($dok)) $dokDir = $dok["DIRECTORY"]."/";
            }
            $dokDir = str_replace("-", "", $dokDir);
            try {
                $this->sftp->login($this->config["username"], $this->config["password"]);
            } catch(\Exception $e) {
                $this->response->setStatusCode(412);
                return (new ApiProblem(412, "Kesalahan authentikasi ke Layanan Penyimpanan Dokumen"))->toArray();
            }
            $data["ID"] = str_replace("-", "", $data["ID"]);
            $tgls = explode(" ", $data["CREATED_DATE"]);
            $tgls = explode("-", $tgls[0]);
            $file = $data["LOCATION"]."/".$dokDir.$tgls[0]."/".$tgls[1]."/".$tgls[2]."/".$data["ID"];
            try {
                $content = $this->sftp->downloadStreamData($file);
            } catch(\Exception $e) {
                $this->response->setStatusCode(412);
                return (new ApiProblem(412, "Gagal pengambilan dokumen dari Layanan Penyimpanan Dokumen"))->toArray();
            }
            $this->crypto->setKey($data["KEY"]);
            $content = $this->crypto->decrypt($content);
            $content = base64_decode($content);
                        
            $this->sftp->disconnect();
            return $this->downloadDocument($content, $data["CONTENT_TYPE"], $data["EXT"], $data["NAME"], $downloadFile);
        }

        $this->response->setStatusCode($result["status"]);
        return $result;
    }

    public function requestAccessAction() {
        $params = (array) $this->getPostData();
        
        if(empty($params["ID"])) {
            if(empty($params["DOCUMENT_DIRECTORY_ID"]) || empty($params["REFERENCE_ID"])) {
                $this->response->setStatusCode(422);
                return [
                    "status" => 422,
                    "success" => false,
                    "detail" => "Parameter ID / (DOCUMENT_DIRECTORY_ID & REFERENCE_ID) harus di isi"
                ];
            }
            if(isset($params["ID"])) unset($params["ID"]);
            if(isset($params["id"])) unset($params["id"]);
        } else {
            $params = [
                "ID" => $params["ID"]
            ];
        }

        $result = [
			"status" => 422,
			"success" => false,
			"detail" => "Parameter request tidak ditemukan"
        ];

        $data = $this->service->load($params, ['*'], ['CREATED_DATE DESC']);
        if(count($data) > 0) {
            $data = $data[0];
            $key = $this->crypto->generateKey(str_replace("-", "", strrev($data["ID"])));
            $this->crypto->setKey($key);
            $data = base64_encode(json_encode($data));
            $data = $this->crypto->encrypt($data);
            $this->storageSession->write($data);

            $result["status"] = 200;
            $result["success"] = true;
            $result["requestAccessNumber"] = $key;
            $result["detail"] = "Request Access Success";
        }

        $this->response->setStatusCode($result["status"]);
        return $result;
    }
    /**
     * Return list of resources
     *
     * @return mixed
     */
	public function getList() {
	    $queries = (array) $this->request->getQuery();
        if(empty($queries["ID"])) {
            if(empty($queries["DOCUMENT_DIRECTORY_ID"]) || empty($queries["REFERENCE_ID"])) {
                $this->response->setStatusCode(422);
                return [
                    "status" => 422,
                    "success" => false,
                    "detail" => "Parameter DOCUMENT_DIRECTORY_ID & REFERENCE_ID harus di isi"
                ];
            }
        }
        
		$data = [];
        $total = $this->service->getRowCount($queries);
        if($total > 0) $data = $this->service->load($queries, ['*'], []);
        foreach($data as &$d) {
            unset($d["LOCATION"]);
            unset($d["KEY"]);
        }

	    return [
	        "status" => $total > 0 ? 200 : 404,
	        "success" => $total > 0 ? true : false,
	        "total" => $total,
	        "data" => $data,
	        "detail" => $this->title." ".($total > 0 ? "ditemukan" : "tidak ditemukan")
	    ];
	}
}
