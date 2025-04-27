<?php
namespace Kemkes\V2\Rpc\Siranap;

use DBService\RPCResource;
use Laminas\View\Model\JsonModel;

use Kemkes\db\siranap\kelas\simrs_kemkes\Service as KelasSimrsKemkesService;
use Kemkes\db\siranap\ruangan\simrs_kemkes\Service as RuanganSimrsKemkesService;
use Kemkes\db\siranap\tempat_tidur\Service as TempatTidurService;

class SiranapController extends RPCResource
{
    private $kelas;
    private $ruangan;

    public function __construct($controller) {
        $this->authType = self::AUTH_TYPE_IP_OR_LOGIN;

        $this->service = new TempatTidurService();

        $this->kelas = new KelasSimrsKemkesService();
        $this->ruangan = new RuanganSimrsKemkesService();
    }

    public function kelasAction() {
        $data = $this->service->getKelas()->load();
        $total = count($data);
        
        return new JsonModel([
            "status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => $total > 0 ? "Kelas ditemukan" : "Kelas tidak ditemukan"
        ]);
    }

    public function kelasSimrsKemkesAction() {
        $request = $this->getRequest();
        $method = $request->getMethod();
        $data = $this->getPostData($request);
        $data = is_array($data) ? $data : (array) $data;

        $result = [
            "status" => 200,
            "success" => true,
            "detail" => "Berhasil menyimpan Kelas Simrs Kemkes"
        ];

        if($method != "GET") {
            if(isset($data["ID"])) {
                if(!is_numeric($data["ID"])) unset($data["ID"]);
            }            
            if(!isset($data["ID"])) {
                if(!isset($data["KELAS"])) {
                    $result["status"] = 422;
                    $result["success"] = false;
                    $result["detail"] = "Kelas Simrs tidak boleh kosong";
                }
                if(!isset($data["KEMKES_KELAS"])) {
                    $result["status"] = 422;
                    $result["success"] = false;
                    $result["metadata"]["message"] = "Kelas Kemkes tidak boleh kosong";
                }
            };            
            
            if($result["status"] == 200) {
                if(!isset($data["ID"])) {
                    $founds = $this->kelas->load([
                        "KELAS" => $data["KELAS"],
                        "KEMKES_KELAS" => $data["KEMKES_KELAS"]
                    ]);
                    if(count($founds) > 0) $data["ID"] = $founds[0]["ID"];
                }
                $success = $this->kelas->simpanData($data, !isset($data["ID"]), false);
                if(!$success) {
                    $result["status"] = 422;
                    $result["success"] = false;
                    $result["detail"] = "Gagal menyimpan Kelas Simrs Kemkes";
                }
            }    
                    
            return $result;
        } else {
            $data = $this->kelas->load();
            if(count($data) > 0) {
                $result["data"] = $data;
                $result["total"] = count($data);
                $result["detail"] = "Kelas Simrs Kemkes ditemukan";
            } else {
                $result["status"] = 404;
                $result["success"] = false;
                $result["data"] = [];
                $result["detail"] = "Kelas Simrs Kemkes tidak ditemukan";
            }
        }

        return new JsonModel($result);
    }

    public function ruanganAction() {
        $data = $this->service->getRuangan()->load();
        $total = count($data);
        
        return new JsonModel([
            "status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => $total > 0 ? "Ruangan ditemukan" : "Ruangan tidak ditemukan"
        ]);
    }

    public function ruanganSimrsKemkesAction() {
        $request = $this->getRequest();
        $method = $request->getMethod();
        $data = $this->getPostData($request);
        $data = is_array($data) ? $data : (array) $data;

        $result = [
            "status" => 200,
            "success" => true,
            "detail" => "Berhasil menyimpan Ruangan Simrs Kemkes"
        ];

        if($method != "GET") {
            if(isset($data["ID"])) {
                if(!is_numeric($data["ID"])) unset($data["ID"]);
            }            
            if(!isset($data["ID"])) {
                if(!isset($data["RUANGAN"])) {
                    $result["status"] = 422;
                    $result["success"] = false;
                    $result["detail"] = "Ruangan Simrs tidak boleh kosong";
                }
                if(!isset($data["KEMKES_RUANGAN"])) {
                    $result["status"] = 422;
                    $result["success"] = false;
                    $result["metadata"]["message"] = "Ruangan Kemkes tidak boleh kosong";
                }
            };            
            
            if($result["status"] == 200) {
                if(!isset($data["ID"])) {
                    $founds = $this->ruangan->load([
                        "RUANGAN" => $data["RUANGAN"],
                        "KEMKES_RUANGAN" => $data["KEMKES_RUANGAN"]
                    ]);
                    if(count($founds) > 0) $data["ID"] = $founds[0]["ID"];
                }
                $success = $this->ruangan->simpanData($data, !isset($data["ID"]), false);
                if(!$success) {
                    $result["status"] = 422;
                    $result["success"] = false;
                    $result["detail"] = "Gagal menyimpan Ruangan Simrs Kemkes";
                }
            }    
                    
            return $result;
        } else {
            $data = $this->ruangan->load();
            if(count($data) > 0) {
                $result["data"] = $data;
                $result["total"] = count($data);
                $result["detail"] = "Ruangan Simrs Kemkes ditemukan";
            } else {
                $result["status"] = 404;
                $result["success"] = false;
                $result["data"] = [];
                $result["detail"] = "Ruangan Simrs Kemkes tidak ditemukan";
            }
        }

        return new JsonModel($result);
    }

    public function tempatTidurAction() { 
        $params = (array) $this->getRequest()->getQuery();        
        $data = $this->service->getWithReference($params);
        $total = count($data);
        
        return new JsonModel([
            "status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => $total > 0 ? "Tempat Tidur ditemukan" : "Tempat Tidur tidak ditemukan"
        ]);
    }    
}
