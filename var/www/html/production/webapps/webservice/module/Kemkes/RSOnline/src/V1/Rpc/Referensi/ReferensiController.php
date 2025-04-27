<?php
namespace Kemkes\RSOnline\V1\Rpc\Referensi;

use DBService\RPCResource;
use Aplikasi\Signature;
use Laminas\View\Model\JsonModel;
use Kemkes\RSOnline\db\referensi\status_rawat\Service as StatusRawatService;
use Kemkes\RSOnline\db\referensi\status_isolasi\Service as StatusIsolasiService;
use Kemkes\RSOnline\db\referensi\sumber_penularan\Service as SumberPenularanService;
use Kemkes\RSOnline\db\referensi\status_keluar\Service as StatusKeluarService;
use Kemkes\RSOnline\db\referensi\jenis_pasien\Service as JenisPasienService;
use Kemkes\RSOnline\db\referensi\kewarganegaraan\Service as KewarganegaraanService;
use Kemkes\RSOnline\db\referensi\jenis_kelamin\Service as JenisKelaminService;
use Kemkes\RSOnline\db\referensi\propinsi\Service as PropinsiService;
use Kemkes\RSOnline\db\referensi\kabupaten\Service as KabupatenService;
use Kemkes\RSOnline\db\referensi\kecamatan\Service as KecamatanService;
use Kemkes\RSOnline\db\referensi\tempat_tidur\Service as TempatTidurService;
use Kemkes\RSOnline\db\referensi\kebutuhan_sdm\Service as KebutuhanSdmService;
use Kemkes\RSOnline\db\referensi\kebutuhan_apd\Service as KebutuhanApdService;

class ReferensiController extends RPCResource
{
    public function __construct($controller) {
        $this->authType = self::AUTH_TYPE_IP_OR_LOGIN;
        $this->jenisBridge = 3;
        
        $this->config = $controller->get('Config');
        $this->config = $this->config['services']['KemkesService'];        
        $this->config = $this->config['RsOnline'];
    }

    protected function onBeforeSendRequest() {
        $this->headers = [
            "Accept: application/json",
            "X-rs-id: ".$this->config["id"],
            "X-pass: ".$this->config["key"]
        ];
        $sign = new Signature(null, null, null);
        $timestamp = $sign->getTimestamp();  
        $this->headers[] = "X-Timestamp: ".$timestamp;
    }

    /* Referensi Status Rawat
	 * Melihat Data Referensi Status Rawat
     * @params loadFromWs = 1	 
	 */
    public function statusRawatAction() {
        $params = (array) $this->getRequest()->getQuery();        
        $service = new StatusRawatService();
        
        if(isset($params["loadFromWs"])) {
            if($params["loadFromWs"]) {
                $response = $this->sendRequestData([
                    "action" => "Referensi/status_rawat",
                    "method" => "GET"
                ]);
                
                $result = $this->getResultRequest($response);
                if($result) {
                    if(isset($result["status"])) {
                        $this->response->setStatusCode(500);
                        return new JsonModel([
                            "status" => 500,
                            "success" => false,
                            "detail" => "Gagal permintaan data ke RS Online. #Silahkan hubungi admin"
                        ]);        
                    }
                    foreach($result["status_rawat"] as $row) {
                        if(isset($row["status"])) {
                            if(is_numeric($row["status"])) {
                                $msg = json_decode($row["message"]);
                                $this->response->setStatusCode(401);
                                return new JsonModel([
                                    "status" => 401,
                                    "success" => false,
                                    "data" => [],
                                    "detail" => $msg->response
                                ]);
                                break;
                            }
                        }

                        $founds = $service->load([
                            "id_status_rawat" => $row["id_status_rawat"]
                        ]);
                        $service->simpanData($row, count($founds) == 0, false);
                    }
                }
            }
        }
        
        $data = $service->load();
        $total = count($data);

        return new JsonModel([
            "status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => $total > 0 ? "Status Rawat ditemukan" : "Status Rawat tidak ditemukan"
        ]);
    }

    /* Referensi Status Isolasi
	 * Melihat Data Referensi Status Isolasi
     * @params loadFromWs = 1, id_status_rawat
	 */
    public function statusIsolasiAction() {
        $params = (array) $this->getRequest()->getQuery();        
        $service = new StatusIsolasiService();
        
        if(isset($params["loadFromWs"])) {
            if($params["loadFromWs"]) {                
                $response = $this->sendRequestData([
                    "action" => "Referensi/status_isolasi",
                    "method" => "GET"
                ]);
                
                $result = $this->getResultRequest($response);
                if($result) {
                    if(isset($result["status"])) {
                        $this->response->setStatusCode(500);
                        return new JsonModel([
                            "status" => 500,
                            "success" => false,
                            "detail" => "Gagal permintaan data ke RS Online. #Silahkan hubungi admin"
                        ]);        
                    }
                    foreach($result["status_isolasi"] as $row) {
                        if(isset($row["status"])) {
                            if(is_numeric($row["status"])) {
                                $msg = json_decode($row["message"]);
                                $this->response->setStatusCode(401);
                                return new JsonModel([
                                    "status" => 401,
                                    "success" => false,
                                    "data" => [],
                                    "detail" => $msg->response
                                ]);
                                break;
                            }
                        }

                        $founds = $service->load([
                            "id_isolasi" => $row["id_isolasi"],
                            "id_status_rawat" => $row["id_status_rawat"]
                        ]);                    
                        $service->simpanData($row, count($founds) == 0, false);
                    }
                }
            }
        }
        $params = isset($params["id_status_rawat"]) ? ["id_status_rawat" => $params["id_status_rawat"]] : [];
        
        $data = $service->load($params);
        $total = count($data);

        return new JsonModel([
            "status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => $total > 0 ? "Status Isolasi ditemukan" : "Status Isolasi tidak ditemukan"
        ]);
    }

    /* Referensi Sumber Penularan
	 * Melihat Data Referensi Sumber Penularan
     * @params loadFromWs = 1
	 */
    public function sumberPenularanAction() {
        $params = (array) $this->getRequest()->getQuery();        
        $service = new SumberPenularanService();
        
        if(isset($params["loadFromWs"])) {
            if($params["loadFromWs"]) {
                $response = $this->sendRequestData([
                    "action" => "Referensi/sebab_penularan",
                    "method" => "GET"
                ]);
                
                $result = $this->getResultRequest($response);                
                if($result) {
                    if(isset($result["status"])) {
                        $this->response->setStatusCode(500);
                        return new JsonModel([
                            "status" => 500,
                            "success" => false,
                            "detail" => "Gagal permintaan data ke RS Online. #Silahkan hubungi admin"
                        ]);        
                    }
                    foreach($result["sebab_penularan"] as $row) {
                        if(isset($row["status"])) {
                            if(is_numeric($row["status"])) {
                                $msg = json_decode($row["message"]);
                                $this->response->setStatusCode(401);
                                return new JsonModel([
                                    "status" => 401,
                                    "success" => false,
                                    "data" => [],
                                    "detail" => $msg->response
                                ]);
                                break;
                            }
                        }

                        $founds = $service->load([
                            "id_source" => $row["id_source"]
                        ]);                    
                        $service->simpanData($row, count($founds) == 0, false);
                    }
                }
            }
        }
        
        $data = $service->load();
        $total = count($data);

        return new JsonModel([
            "status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => $total > 0 ? "Sebab Penularan ditemukan" : "Sebab Penularan tidak ditemukan"
        ]);
    }

    /* Referensi Status Keluar
	 * Melihat Data Referensi Status Keluar
     * @params loadFromWs = 1
	 */
    public function statusKeluarAction() {
        $params = (array) $this->getRequest()->getQuery();        
        $service = new StatusKeluarService();
        
        if(isset($params["loadFromWs"])) {
            if($params["loadFromWs"]) {
                $response = $this->sendRequestData([
                    "action" => "Referensi/status_keluar",
                    "method" => "GET"
                ]);
                
                $result = $this->getResultRequest($response);
                if($result) {
                    if(isset($result["status"])) {
                        $this->response->setStatusCode(500);
                        return new JsonModel([
                            "status" => 500,
                            "success" => false,
                            "detail" => "Gagal permintaan data ke RS Online. #Silahkan hubungi admin"
                        ]);        
                    }
                    foreach($result["status_keluar"] as $row) {
                        if(isset($row["status"])) {
                            if(is_numeric($row["status"])) {
                                $msg = json_decode($row["message"]);
                                $this->response->setStatusCode(401);
                                return new JsonModel([
                                    "status" => 401,
                                    "success" => false,
                                    "data" => [],
                                    "detail" => $msg->response
                                ]);
                                break;
                            }
                        }

                        $founds = $service->load([
                            "id_status" => $row["id_status"]
                        ]);                    
                        $service->simpanData($row, count($founds) == 0, false);
                    }
                }
            }
        }
        
        $data = $service->load();
        $total = count($data);

        return new JsonModel([
            "status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => $total > 0 ? "Status Keluar ditemukan" : "Status Keluar tidak ditemukan"
        ]);
    }

    /* Referensi Jenis Pasien
	 * Melihat Data Referensi Jenis Pasien
     * @params loadFromWs = 1
	 */
    public function jenisPasienAction() {
        $params = (array) $this->getRequest()->getQuery();        
        $service = new JenisPasienService();
        
        if(isset($params["loadFromWs"])) {
            if($params["loadFromWs"]) {
                $response = $this->sendRequestData([
                    "action" => "Referensi/jenis_pasien",
                    "method" => "GET"
                ]);
                
                $result = $this->getResultRequest($response);
                if($result) {
                    if(isset($result["status"])) {
                        $this->response->setStatusCode(500);
                        return new JsonModel([
                            "status" => 500,
                            "success" => false,
                            "detail" => "Gagal permintaan data ke RS Online. #Silahkan hubungi admin"
                        ]);        
                    }
                    foreach($result["jenis_pasien"] as $row) {
                        if(isset($row["status"])) {
                            if(is_numeric($row["status"])) {
                                $msg = json_decode($row["message"]);
                                $this->response->setStatusCode(401);
                                return new JsonModel([
                                    "status" => 401,
                                    "success" => false,
                                    "data" => [],
                                    "detail" => $msg->response
                                ]);
                                break;
                            }
                        }

                        $founds = $service->load([
                            "id_jenis_pasien" => $row["id_jenis_pasien"]
                        ]);                    
                        $service->simpanData($row, count($founds) == 0, false);
                    }
                }
            }
        }
        
        $data = $service->load();
        $total = count($data);

        return new JsonModel([
            "status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => $total > 0 ? "Jenis Pasien ditemukan" : "Jenis Pasien tidak ditemukan"
        ]);
    }

    /* Referensi Kewarganegaraan
	 * Melihat Data Referensi Kewarganegaraan
     * @params loadFromWs = 1
	 */
    public function kewarganegaraanAction() {
        $params = (array) $this->getRequest()->getQuery();        
        $service = new KewarganegaraanService();
        
        if(isset($params["loadFromWs"])) {
            if($params["loadFromWs"]) {
                $response = $this->sendRequestData([
                    "action" => "Referensi/kewarganegaraan",
                    "method" => "GET"
                ]);
                
                $result = $this->getResultRequest($response);
                if($result) {
                    if(isset($result["status"])) {
                        $this->response->setStatusCode(500);
                        return new JsonModel([
                            "status" => 500,
                            "success" => false,
                            "detail" => "Gagal permintaan data ke RS Online. #Silahkan hubungi admin"
                        ]);        
                    }
                    foreach($result["kewarganegaraan"] as $row) {
                        if(isset($row["status"])) {
                            if(is_numeric($row["status"])) {
                                $msg = json_decode($row["message"]);
                                $this->response->setStatusCode(401);
                                return new JsonModel([
                                    "status" => 401,
                                    "success" => false,
                                    "data" => [],
                                    "detail" => $msg->response
                                ]);
                                break;
                            }
                        }

                        $founds = $service->load([
                            "id_nation" => $row["id_nation"]
                        ]);                    
                        $service->simpanData($row, count($founds) == 0, false);
                    }
                }
            }
        }
        
        $data = $service->load();
        $total = count($data);

        return new JsonModel([
            "status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => $total > 0 ? "Kewarganegaraan ditemukan" : "Kewarganegaraan tidak ditemukan"
        ]);
    }

    /* Referensi Jenis Kelamin
	 * Melihat Data Referensi Jenis Kelamin
     * @params loadFromWs = 1
	 */
    public function jenisKelaminAction() {
        $params = (array) $this->getRequest()->getQuery();        
        $service = new JenisKelaminService();
        
        if(isset($params["loadFromWs"])) {
            if($params["loadFromWs"]) {
                $response = $this->sendRequestData([
                    "action" => "Referensi/jenis_kelamin",
                    "method" => "GET"
                ]);
                
                $result = $this->getResultRequest($response);                
                if($result) {
                    if(isset($result["status"])) {
                        $this->response->setStatusCode(500);
                        return new JsonModel([
                            "status" => 500,
                            "success" => false,
                            "detail" => "Gagal permintaan data ke RS Online. #Silahkan hubungi admin"
                        ]);        
                    }
                    foreach($result["jenis_kelamin"] as $row) {
                        if(isset($row["status"])) {
                            if(is_numeric($row["status"])) {
                                $msg = json_decode($row["message"]);
                                $this->response->setStatusCode(401);
                                return new JsonModel([
                                    "status" => 401,
                                    "success" => false,
                                    "data" => [],
                                    "detail" => $msg->response
                                ]);
                                break;
                            }
                        }

                        $founds = $service->load([
                            "id_gender" => $row["id_gender"]
                        ]);                    
                        $service->simpanData($row, count($founds) == 0, false);
                    }
                }
            }
        }
        
        $data = $service->load();
        $total = count($data);

        return new JsonModel([
            "status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => $total > 0 ? "Jenis Kelamin ditemukan" : "Jenis Kelamin tidak ditemukan"
        ]);
    }

    /* Referensi Propinsi
	 * Melihat Data Referensi Propinsi
     * @params loadFromWs = 1
	 */
    public function propinsiAction() {
        $params = (array) $this->getRequest()->getQuery();        
        $service = new PropinsiService();
        
        if(isset($params["loadFromWs"])) {
            if($params["loadFromWs"]) {
                $response = $this->sendRequestData([
                    "action" => "Referensi/propinsi",
                    "method" => "GET"
                ]);
                
                $result = $this->getResultRequest($response);                
                if($result) {
                    if(isset($result["status"])) {
                        $this->response->setStatusCode(500);
                        return new JsonModel([
                            "status" => 500,
                            "success" => false,
                            "detail" => "Gagal permintaan data ke RS Online. #Silahkan hubungi admin"
                        ]);        
                    }
                    foreach($result["propinsi"] as $row) {
                        if(isset($row["status"])) {
                            if(is_numeric($row["status"])) {                                
                                $msg = json_decode($row["message"]);
                                $this->response->setStatusCode(401);
                                return new JsonModel([
                                    "status" => 401,
                                    "success" => false,
                                    "data" => [],
                                    "detail" => $msg->response
                                ]);
                                break;
                            }
                        }
                        
                        $founds = $service->load([
                            "prop_kode" => $row["prop_kode"]
                        ]);                    
                        $service->simpanData($row, count($founds) == 0, false);
                    }
                }
            }
        }
                
        $data = $service->load();
        $total = count($data);

        return new JsonModel([
            "status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => $total > 0 ? "Propinsi ditemukan" : "Propinsi tidak ditemukan"
        ]);
    }

    /* Referensi Kabupaten
	 * Melihat Data Referensi Kabupaten
     * @params loadFromWs = 1
	 */
    public function kabupatenAction() {
        $params = (array) $this->getRequest()->getQuery();        
        $service = new KabupatenService();
        $prop = (isset($params["propinsi"]) ? $params["propinsi"] : "");
        
        if(isset($params["loadFromWs"])) {
            if($params["loadFromWs"]) {
                $prop = ($prop == "" ? substr($this->config["id"], 0, 2) : $prop);
                $response = $this->sendRequestData([
                    "action" => "Referensi/Kabupaten",
                    "method" => "POST",
                    "data" => [
                        "propinsi" => $prop
                    ]
                ]);
                
                $result = $this->getResultRequest($response);                
                if($result) {
                    if(isset($result["status"])) {
                        $this->response->setStatusCode(500);
                        return new JsonModel([
                            "status" => 500,
                            "success" => false,
                            "detail" => "Gagal permintaan data ke RS Online. #Silahkan hubungi admin"
                        ]);        
                    }

                    $kabupaten = isset($result["kabupaten"]) ? $result["kabupaten"] : $result["kabupaten - ".$prop];
                    if(!isset($kabupaten["status"])) {   
                        foreach($kabupaten as $row) {
                            if(isset($row["status"])) {
                                if(is_numeric($row["status"])) {
                                    $msg = json_decode($row["message"]);
                                    $this->response->setStatusCode(401);
                                    return new JsonModel([
                                        "status" => 401,
                                        "success" => false,
                                        "data" => [],
                                        "detail" => $msg->response
                                    ]);
                                    break;
                                }
                            }

                            $founds = $service->load([
                                "kode" => $row["kode"],
                                "propinsi" => $prop
                            ]);
                            $row["propinsi"] = $prop;
                            $service->simpanData($row, count($founds) == 0, false);
                        }
                    } else {
                        $this->response->setStatusCode(404);
                        return new JsonModel([
                            "status" => 404,
                            "success" => false,
                            "data" => [],
                            "detail" => $kabupaten["message"]
                        ]);
                    }
                }
            }
        }
        
        $data = $service->load([
            "propinsi" => $prop
        ], ["*"], ["kode ASC"]);
        $total = count($data);

        return new JsonModel([
            "status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => $total > 0 ? "Kabupaten ditemukan" : "Kabupaten tidak ditemukan"
        ]);
    }

    /* Referensi Kecamatan
	 * Melihat Data Referensi Kecamatan
     * @params loadFromWs = 1
	 */
    public function kecamatanAction() {
        $params = (array) $this->getRequest()->getQuery();        
        $service = new KecamatanService();
        $kabkota = (isset($params["kabkota"]) ? $params["kabkota"] : "");
        
        if(isset($params["loadFromWs"])) {
            if($params["loadFromWs"]) {
                $kabkota = ($kabkota == "") ? substr($this->config["id"], 0, 4) : $kabkota;
                $response = $this->sendRequestData([
                    "action" => "Referensi/Kecamatan",
                    "method" => "POST",
                    "data" => [
                        "kabkota" => $kabkota
                    ]
                ]);
                
                $result = $this->getResultRequest($response);                
                if($result) {
                    if(isset($result["status"])) {
                        $this->response->setStatusCode(500);
                        return new JsonModel([
                            "status" => 500,
                            "success" => false,
                            "detail" => "Gagal permintaan data ke RS Online. #Silahkan hubungi admin"
                        ]);        
                    }           
                    $kecamatan = isset($result["kecamatan"]) ? $result["kecamatan"] : $result["kecamatan - ".$kabkota];
                    if(!isset($kecamatan["status"])) {
                        foreach($kecamatan as $row) {
                            if(isset($row["status"])) {
                                if(is_numeric($row["status"])) {
                                    $msg = json_decode($row["message"]);                                    
                                    $this->response->setStatusCode(401);
                                    return new JsonModel([
                                        "status" => 401,
                                        "success" => false,
                                        "data" => [],
                                        "detail" => $msg->response
                                    ]);
                                    break;
                                }
                            }                            
                            $founds = $service->load([
                                "kode" => $row["kode"],
                                "kabkota" => $kabkota
                            ]);
                            $row["kabkota"] = $kabkota;                            
                            $service->simpanData($row, count($founds) == 0, false);
                        }
                    } else {
                        $this->response->setStatusCode(404);
                        return new JsonModel([
                            "status" => 404,
                            "success" => false,
                            "data" => [],
                            "detail" => $kecamatan["message"]
                        ]);
                    }
                }
            }
        }
        
        $data = $service->load([
            "kabkota" => $kabkota
        ], ["*"], ["kode ASC"]);
        $total = count($data);

        return new JsonModel([
            "status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => $total > 0 ? "Kecamatan ditemukan" : "Kecamatan tidak ditemukan"
        ]);
    }

    /* Referensi Tempat Tidur
	 * Melihat Data Referensi Tempat Tidur
     * @params loadFromWs = 1
	 */
    public function tempatTidurAction() {
        $params = (array) $this->getRequest()->getQuery();        
        $service = new TempatTidurService();
        
        if(isset($params["loadFromWs"])) {
            if($params["loadFromWs"]) {
                $response = $this->sendRequestData([
                    "action" => "Referensi/tempat_tidur",
                    "method" => "GET"
                ]);
                    
                $result = $this->getResultRequest($response);
                if($result) {
                    if(isset($result["status"])) {
                        $this->response->setStatusCode(500);
                        return new JsonModel([
                            "status" => 500,
                            "success" => false,
                            "detail" => "Gagal permintaan data ke RS Online. #Silahkan hubungi admin"
                        ]);        
                    }
                    foreach($result["tempat_tidur"] as $row) {
                        if(isset($row["status"])) {
                            if(is_numeric($row["status"])) {
                                $msg = json_decode($row["message"]);
                                $this->response->setStatusCode(401);
                                return new JsonModel([
                                    "status" => 401,
                                    "success" => false,
                                    "data" => [],
                                    "detail" => $msg->response
                                ]);
                                break;
                            }
                        }

                        $founds = $service->load([
                            "kode_tt" => $row["kode_tt"]
                        ]);                    
                        $service->simpanData($row, count($founds) == 0, false);
                    }
                }
            }
        }
        
        $data = $service->load([
            "status" => 1
        ]);
        $total = count($data);

        return new JsonModel([
            "status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => $total > 0 ? "Tempat Tidur ditemukan" : "Tempat Tidur tidak ditemukan"
        ]);        
    }

    /* Referensi Kebutuhan SDM
	 * Melihat Data Referensi Kebutuhan SDM
     * @params loadFromWs = 1
	 */
    public function kebutuhanSdmAction() {
        $params = (array) $this->getRequest()->getQuery();        
        $service = new KebutuhanSdmService();
        
        if(isset($params["loadFromWs"])) {
            if($params["loadFromWs"]) {
                $response = $this->sendRequestData([
                    "action" => "Referensi/kebutuhan_sdm",
                    "method" => "GET"
                ]);
                    
                $result = $this->getResultRequest($response);                
                if($result) {
                    if(isset($result["status"])) {
                        $this->response->setStatusCode(500);
                        return new JsonModel([
                            "status" => 500,
                            "success" => false,
                            "detail" => "Gagal permintaan data ke RS Online. #Silahkan hubungi admin"
                        ]);        
                    }
                    foreach($result["kebutuhan_sdm"] as $row) {
                        if(isset($row["status"])) {
                            if(is_numeric($row["status"])) {
                                $msg = json_decode($row["message"]);
                                $this->response->setStatusCode(401);
                                return new JsonModel([
                                    "status" => 401,
                                    "success" => false,
                                    "data" => [],
                                    "detail" => $msg->response
                                ]);
                                break;
                            }
                        }

                        $founds = $service->load([
                            "id_kebutuhan" => $row["id_kebutuhan"]
                        ]);                    
                        $service->simpanData($row, count($founds) == 0, false);
                    }
                }
            }
        }
        
        $data = $service->load();
        $total = count($data);

        return new JsonModel([
            "status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => $total > 0 ? "Kebutuhan SDM ditemukan" : "Kebutuhan SDM tidak ditemukan"
        ]);
    }

    /* Referensi Kebutuhan APD
	 * Melihat Data Referensi Kebutuhan APD
     * @params loadFromWs = 1
	 */
    public function kebutuhanApdAction() {
        $params = (array) $this->getRequest()->getQuery();        
        $service = new KebutuhanApdService();
        
        if(isset($params["loadFromWs"])) {
            if($params["loadFromWs"]) {
                $response = $this->sendRequestData([
                    "action" => "Referensi/kebutuhan_apd",
                    "method" => "GET"
                ]);
                    
                $result = $this->getResultRequest($response);                
                if($result) {
                    if(isset($result["status"])) {
                        $this->response->setStatusCode(500);
                        return new JsonModel([
                            "status" => 500,
                            "success" => false,
                            "detail" => "Gagal permintaan data ke RS Online. #Silahkan hubungi admin"
                        ]);        
                    }
                    foreach($result["kebutuhan_apd"] as $row) {
                        if(isset($row["status"])) {
                            if(is_numeric($row["status"])) {
                                $msg = json_decode($row["message"]);
                                $this->response->setStatusCode(401);
                                return new JsonModel([
                                    "status" => 401,
                                    "success" => false,
                                    "data" => [],
                                    "detail" => $msg->response
                                ]);
                                break;
                            }
                        }

                        $founds = $service->load([
                            "id_kebutuhan" => $row["id_kebutuhan"]
                        ]);                    
                        $service->simpanData($row, count($founds) == 0, false);
                    }
                }
            }
        }
        
        $data = $service->load();
        $total = count($data);

        return new JsonModel([
            "status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => $total > 0 ? "Kebutuhan APD ditemukan" : "Kebutuhan APD tidak ditemukan"
        ]);        
    }

    public function testAction() {
        $response = $this->sendRequestData([
            "action" => "Pasien",
            "method" => "GET"
        ]);
            
        $result = $this->getResultRequest($response);
        return $result;
    }

    public function testKabupatenAction() {
        $params = (array) $this->getRequest()->getQuery();
        $response = $this->sendRequestData([
            "action" => "Referensi/Kabupaten",
            "method" => "GET",
            "data" => [
                "propinsi" => $params["propinsi"]
            ]
        ]);
            
        $result = $this->getResultRequest($response);
        return $result;
    }

    public function testKecamatanAction() {
        $params = (array) $this->getRequest()->getQuery();
        $response = $this->sendRequestData([
            "action" => "Referensi/Kecamatan",
            "method" => "GET",
            "data" => [
                "kabkota" => $params["kabkota"]
            ]
        ]);
            
        $result = $this->getResultRequest($response);
        return $result;
    }
}