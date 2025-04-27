<?php
/**
 * BPJService
 * @author hariansyah
 * 
 */
 
namespace BPJService\VClaim\v_2_0;

use BPJService\VClaim\v_1_1\Service as BaseService;
use Laminas\Json\Json;
use BPJService\db\lpk\Service as LPKStore;

class LPKService extends BaseService {
	protected $store;

	function __construct($config) {
		parent::__construct($config);

		$this->store = new LPKStore();
	}

	protected function sendRequest($action = "", $method = "GET", $data = "", $contenType = "application/json", $url = "") {
		$result = parent::sendRequest($action, $method, $data, $contenType, $url);
		$result = Json::decode($result);
		if(is_object($result)) if($result->response) $result->response = $this->decrypt($result->response);
		return Json::encode($result);
	}

	/** 
	 * Lembar Pengajuan Klaim
	 * Insert / Update / Delete
	 * @parameter 
	 *   $method default POST
	 *   $params [
	 *      "noSep" => value,				POST	PUT		DELETE
	 *      "tglMasuk" => value,			POST	PUT		-		| tanggal masuk format yyyy-mm-dd
	 *      "tglKeluar" => value,			POST	PUT		-		| tanggal keluar format yyyy-mm-dd
	 *	    "jaminan" => value, 			POST	PUT		-		| penjamin -> 1. JKN
	 *		"poli" => [						POST	PUT		-
	 *	 		"poli" => value | kode poli -> data di referensi poli
	 *       ],
	 *		"perawatan" => [				POST	PUT		-
	 *	 		"ruangRawat" => value, | ruang rawat -> data di referensi ruang rawat
	 *	 		"kelasRawat" => value, | kelas rawat -> data di referensi kelas rawat
	 *	 		"spesialistik" => value, | spesialistik -> data di referensi spesialistik
	 *	 		"caraKeluar" => value, | cara keluar -> data di referensi cara keluar
	 *	 		"kondisiPulang" => value | kondisi pulang -> data di referensi kondisi pulang
	 *       ],
	 *		"diagnosa" => [[				POST	PUT		-
	 *	 		"kode" => value | kode diagnosa  -> data di referensi diagnosa
	 *	 		"level" => value | level diagnosa -> 1.Primer 2.Sekunder
	 *       ]],
	 *		"procedure" => [[				POST	PUT		-
	 *	 		"kode" => value | kode procedure -> data di referensi procedure/tindakan
	 *       ]],
	 *		"rencanaTL" => [				POST	PUT		-
	 *	 		"tindakLanjut" => value | tindak lanjut -> 1:Diperbolehkan Pulang, 2:Pemeriksaan Penunjang, 3:Dirujuk Ke, 4:Kontrol Kembali
	 *	 		"dirujukKe" => [
	 *	 			"kodePPK" => value | kode faskes -> data di referensi faskes
	 *	 		],
	 *	 		"kontrolKembali" => [
	 *	 			"tglKontrol" => value | tanggal kontrol kembali format : yyyy-mm-dd
	 *	 			"poli" => value | kode poli -> data di referensi poli
	 *	 		]
	 *       ],
	 *		"DPJP" => value, 				POST	PUT		-		| kode dokter dpjp -> data di referensi dokter
	 *		"user" => value					POST	PUT		-		| user pemakai
	 *   ]
	 *   	 
	 */
	function lpk($method = "POST", $params) {
		$data = json_encode([
			"request" => [
				"t_lpk" => $params
			]
		]);

		$uris = [
			"POST" => "LPK/insert",
			"PUT"  => "LPK/update",
			"DELETE" => "LPK/delete"
		];
		
		$result =  json_decode($this->sendRequest($uris[$method], "POST", $data, "application/x-www-form-urlencoded"));		
		if($result) {
			$message = trim($result->metadata->message);
			$result->metadata->requestId = $this->config["koders"];			
			if($result->metadata->code == 200) {
				if($method == "DELETE") $params["status"] = 0; 
				$this->store->simpanData($params, $method == "POST", false);
			} else {
				if($result->metadata != null) {
					$message = $result->metadata->code."-".$message;
				}
			}
		} else {
			return json_decode(json_encode([
				'metadata' => [
					'message' => "SIMRSInfo::Error Request Service - Lembar Pengajuan Klaim (LPK)<br/>".$this::RESULT_IS_NULL,
					'code' => 502,
					'requestId'=> $this->config["koders"]
				]
			]));
		}
		
		return $result;
	}

	/** 
	 * Lembar Pengajuan Klaim>>>Data Lembar Pengajuan Klaim
	 * @method list
	 * @parameter 
	 *   $params [ 
	 *       "TglMasuk" => value | Tanggal Masuk - format : yyyy-MM-dd
	 *       , "JnsPelayanan" => value | Jenis Pelayanan 1. Inap 2.Jalan
	 *   ],
	 *   $uri string
	 */
	function list($params, $uri = "LPK") {
		$masuk = "/"."TglMasuk/";
		$jns = "/"."JnsPelayanan/";
	    if(is_array($params)) {
			if(isset($params["TglMasuk"])) $masuk .= $params["TglMasuk"];
			if(isset($params["tglAkhir"])) $jns .= $params["JnsPelayanan"];
	    }

		$result = Json::decode($this->sendRequest($uri.$masuk.$jns));
		if($result) {
			$result->metadata->requestId = $this->config["koders"];
	        if($result->response) {
	            $data = isset($result->response->lpk->list) ? (array) $result->response->lpk->list : [];
	            $result->response->list = $data;
	            $result->response->count = count($data);
	        }
		} else {
			return json_decode(json_encode([
				'metadata' => [
					'message' => "SIMRSInfo::Error Request Service - Data Lembar Pengajuan Klaim<br/>".$this::RESULT_IS_NULL,
					'code' => 502,
					'requestId'=> $this->config["koders"]
				]
			]));
		}
		return $result;
	}
}