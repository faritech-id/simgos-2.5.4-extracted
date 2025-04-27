<?php
namespace BPJService\V1\Rpc\Aplicares;

use DBService\RPCResource;
use Laminas\View\Model\JsonModel;
use Aplikasi\Signature;
use \DateTime;
use \DateTimeZone;

use BPJService\db\referensi\kamar\Service as KamarService;
use BPJService\db\tempat_tidur\Service as TempatTidurService;
use BPJService\db\map_kelas\Service as MapKelasService;

class AplicaresController extends RPCResource
{
    private $signature;    
    private $mapKelas;

    CONST RESULT_IS_NULL = "Silahkan hubungi BPJS respon data null";

    public function __construct($controller) {
        $this->authType = self::AUTH_TYPE_IP_OR_LOGIN;
        
        $this->config = $controller->get('Config');
        $this->config = $this->config['services']['BPJService'];
        $this->config = $this->config['aplicares'];                

        $this->signature = new Signature("", "", "");
        $this->jenisBridge = 1;

        $this->service = new TempatTidurService();
        $this->mapKelas = new MapKelasService();
    }

    protected function onBeforeSendRequest() {
        $this->headers = [
            "Accept: application/json",
            "X-cons-id: ".$this->config["id"]
        ];
        $dt = new DateTime(null, new DateTimeZone("UTC"));
        $timestamp = $dt->getTimestamp();
        $this->headers[] = "X-Timestamp: ".$timestamp;
        
        $sign = $this->signature->generateSign([
            "X_ID" => $this->config["id"],
            "X_PASS" => $this->config["key"]
        ], $timestamp);
        $this->headers[] = "X-signature: ".$sign;
    }

    /* Referensi Kamar
	 * Melihat Data Referensi Kamar	 
	 */
    public function referensiKamarAction() {
        $service = new KamarService();
        
        $response = $this->sendRequestData([
            "action" => "ref/kelas",
            "method" => "GET"
        ]);
        
        $result = $this->getResultRequest($response);
        if($result) {
            if(isset($result["response"])) {
                $list = isset($result["response"]["list"]) ? $result["response"]["list"] : [];
                foreach($list as $row) {
                    $founds = $service->load([
                        "kodekelas" => $row["kodekelas"]
                    ]);                    
                    $service->simpanData($row, count($founds) == 0, false);
                }
                $kelas = $service->load();
                $result["response"]["list"] = $kelas;
                $result["response"]["count"] = count($kelas);
                $result["metadata"]["code"] = 200;
            }
        } else {
            $result = json_decode(json_encode([
                'metadata' => [
                    'message' => "SIMRSInfo::Error Request Service - Aplicares Referensi Kamar<br/>".$this::RESULT_IS_NULL,
                    'code' => 502
                ]
            ]));
        }
        
        return new JsonModel([
            'data' => $result
        ]);
    }

    /* Ketersedian Kamar RS
	 * Melihat Data Ketersediaan Kamar RS
	 * @parameter 
	 *   $params array("faskes" => value, "start" => value, "limit" => value)
	 */
    public function ketersediaanKamarRSAction() {        
        $params = (array) $this->getRequest()->getQuery();   
        $params["faskes"] = isset($params["faskes"]) && !empty($params["faskes"]) ? $params["faskes"] : $this->config["koders"];
        $params["start"] = isset($params["start"]) && !empty($params["start"]) ? $params["start"] : 0;
        $params["limit"] = isset($params["limit"]) && !empty($params["limit"]) ? $params["limit"] : 25;

        $response = $this->sendRequestData([
            "action" => "bed/read/".$params["faskes"]."/".$params["start"]."/".$params["limit"],
            "method" => "GET"
        ]);
        $response = str_replace("metaData", "metadata", $response);
        $response = str_replace("Code", "code", $response);
        $result = $this->getResultRequest($response);

        if($result) {
            if(isset($result["response"])) {
                $result["response"]["count"] = $result["metadata"]["totalitems"];
                $result["metadata"]["code"] = 200;
            }
        } else {
            $result = json_decode(json_encode([
                'metadata' => [
                    'message' => "SIMRSInfo::Error Request Service - Aplicares Ketersediaan Kamar RS<br/>".$this::RESULT_IS_NULL,
                    'code' => 502
                ]
            ]));
        }
        
        return new JsonModel([
            'data' => $result
        ]);
    }

    /* Kirim Informasi Tempat Tidur
	 * Buat scheduler untuk mengeksekusi ws ini
     * Tidak termasuk dalam ws aplicares	 
	 */
    public function kirimAction() {           
        /* ambil data tempat tidur */
	    $params = [
            "start" => 0,
	        "limit" => 10
	    ];
        $params[] = "kirim = 1";
        
        $froms = $this->service->load($params, array('*'), array('tanggal_updated ASC'));
	    foreach($froms as &$row) {
	        $params = [
	            "kodekelas" => $row["kodekelas"],
                "koderuang" => $row["koderuang"],
                "namaruang" => $row["namaruang"],
                "kapasitas" => $row["kapasitas"],
                "tersedia" => $row["tersedia"],
                "tersediapria" => $row["tersediapria"],
                "tersediawanita" => $row["tersediawanita"],
                "tersediapriawanita" => $row["tersediapriawanita"],
            ];
            
	        $uri = "bed/";
            if($row["ruang_baru"] == 1) $uri .= "create";
            elseif($row["hapus_ruang"] == 1) {
                $uri .= "delete";
                unset($params["namaruang"]);
                unset($params["kapasitas"]);
                unset($params["tersedia"]);
                unset($params["tersediapria"]);
                unset($params["tersediawanita"]);
                unset($params["tersediapriawanita"]);
            } else $uri .= "update";

            $uri .= "/".$this->config["koders"];
	        
	        /* kirim data */
	        $response = $this->sendRequestData([
	            "action" => $uri,
	            "method" => "POST",
	            "data" => $params
            ]);
            
	        $result = $this->getResultRequest($response);
            
            if($result) {
                if(isset($result["metadata"])) {
                    if($result["metadata"]['code'] == 1) {
                        if($row["hapus_ruang"] == 0) {
                            $row["ruang_baru"] = 0;
                            $row["kirim"] = 0;
                            $this->service->simpanData($row, false, false);
                        } else {
                            $this->service->hapus([
                                "id" => $row['id']
                            ]);
                        }
                    }
                }
            }
	    }
	    
	    return [
	        "data" => $froms
	    ];
    }
    
    /* Tempat Tidur
	 * Informasi Tempat Tidur
     * Tidak termasuk dalam ws aplicares
	 * @parameter 
	 *   $params array("start" => value, "limit" => value)
	 */
    public function tempatTidurAction() { 
        $params = (array) $this->getRequest()->getQuery();
        $prms = [];
        $prms["start"] = isset($params["start"]) ? $params["start"] : 0;
        $prms["limit"] = isset($params["limit"]) ? $params["limit"] : 5000;
        
        $data = [];
        $total = $this->service->getRowCount($prms);
        if($total > 0) $data = $this->service->load($prms);
        
        return new JsonModel([
            'data' => [
                "response" => [
                    "list" => $data,
                    "count" => $total
                ],
                "metadata" => [
                    "code" => $total > 0 ? 200 : 404,
                    "message" => $total > 0 ? "OK" : "Tempat tidur tidak ditemukan"
                ]
            ]
        ]);
    }

    /* Hapus Tempat Tidur
	 * Hapus Tempat Tidur
     * Tidak termasuk dalam ws aplicares
	 * @parameter post
	 *   $params array("id" => value)
	 */
    public function hapusTempatTidurAction() { 
        $data = $this->getPostData($this->getRequest());
        $data = is_array($data) ? $data : (array) $data;

        $result = [
            "response" => [],
            "metadata" => [
                "code" => 200,
                "message" => "Sukses"
            ]
        ];

        if(!isset($data["id"])) {
            $result["metadata"]["code"] = 422;
            $result["metadata"]["message"] = "id tidak boleh kosong";
        } else {
            $this->service->simpanData([
                "id" => $data["id"],
                "hapus_ruang" => 1,
                "kirim" => 1
            ], false, false);
        }        

        return new JsonModel([
            'data' => $result
        ]);
    }

    /* Map Kelas
	 * Map Kelas Aplicares & RS
     * Tidak termasuk dalam ws aplicares
	 * @parameter post
	 *   $params array("kelas" => value, "kelas_rs" => value)
	 */
    public function mapKelasAction() {
        $request = $this->getRequest();
        $method = $request->getMethod();
        $data = $this->getPostData($request);
        $data = is_array($data) ? $data : (array) $data;

        $result = [
            "response" => [],
            "metadata" => [
                "code" => 200,
                "message" => "Sukses"
            ]
        ];
        
        if($method != "GET") {
            if(isset($data["id"])) {
                if(!is_numeric($data["id"])) unset($data["id"]);
            }            
            if(!isset($data["id"])) {
                if(!isset($data["kelas"])) {
                    $result["metadata"]["code"] = 422;
                    $result["metadata"]["message"] = "kelas aplicares tidak boleh kosong";
                } 
                if(!isset($data["kelas_rs"])) {
                    $result["metadata"]["code"] = 422;
                    $result["metadata"]["message"] = "kelas rs tidak boleh kosong";
                }
            }

            if($result["metadata"]["code"] == 200) {
                if(!isset($data["id"])) {
                    $founds = $this->mapKelas->load($data);
                    if(count($founds) > 0) $data["id"] = $founds[0]["id"];
                }
                $this->mapKelas->simpanData($data, !isset($data["id"]), false);
                $this->service->executeTempatTidur();
            } 
        } else {
            $data = $this->mapKelas->load();
            if(count($data) > 0) {
                $result["response"] = [
                    "list" => $data,
                    "count" => count($data)
                ];
            } else {
                $result["metadata"]["code"] = 404;
                $result["metadata"]["message"] = "Data Map Kelas tidak ditemukan";
            }
        } 

        return new JsonModel([
            'data' => $result
        ]);
    }
}