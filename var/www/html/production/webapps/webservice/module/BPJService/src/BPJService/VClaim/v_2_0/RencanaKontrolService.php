<?php
/**
 * BPJService
 * @author hariansyah
 * 
 */
 
namespace BPJService\VClaim\v_2_0;

use BPJService\VClaim\v_1_1\Service as BaseService;
use Laminas\Json\Json;
use BPJService\db\rencana_kontrol\Service as RencanaKontrolStore;

class RencanaKontrolService extends BaseService {
	protected $store;
	
	function __construct($config) {
		parent::__construct($config);

		$this->store = new RencanaKontrolStore();
	}

	protected function sendRequest($action = "", $method = "GET", $data = "", $contenType = "application/json", $url = "") {
		$result = parent::sendRequest($action, $method, $data, $contenType, $url);
		$result = Json::decode($result);
		if(is_object($result)) if($result->response) $result->response = $this->decrypt($result->response);
		return Json::encode($result);
	}
	
	/** Rencana Kontrol & SPRI
	 * Insert / Update / Delete
	 * @parameter 
	 *   $method default POST
	 *   $params [
	 *      "noSurat" => value,								-		PUT		DELETE		
	 *      "jnsKontrol" => value, | 1 = SPRI; 2 = Surat Kontrol								
	 *	    "nomor" => value, | noSEP & noKartu				POST	PUT		-
	 *		"kodeDokter" => value,							POST	PUT		-
	 *		"poliKontrol" => value,							POST	PUT		-
	 *		"tglRencanaKontrol" => value, | yyyy-MM-dd		POST	PUT		-
	 *		"user" => value									POST	PUT		DELETE
	 *   ]	 
	 */
	function rencanaKontrol($method = "POST", $params) {
		$prms = $params;
		$jns = !empty($params["jnsKontrol"]) ? $params["jnsKontrol"] : 1;
		unset($params["jnsKontrol"]);
		if(isset($params["tglRencanaKontrol"])) {
			$params["tglRencanaKontrol"] = substr($params["tglRencanaKontrol"], 0, 10);
		}

		if($jns == 1) {
			$params["noKartu"] = !empty($params["nomor"]) ? $params["nomor"] : "";
			unset($params["nomor"]);
			if($method == "PUT") {
				$params["noSPRI"] = !empty($params["noSurat"]) ? $params["noSurat"] : "";
				unset($params["noSurat"]);
			}
		}

		if($jns == 2) {
			$params["noSEP"] = !empty($params["nomor"]) ? $params["nomor"] : "";
			unset($params["nomor"]);
			if($method == "PUT") {
				$params["noSuratKontrol"] = !empty($params["noSurat"]) ? $params["noSurat"] : "";
				unset($params["noSurat"]);
			}
		}

		if($method == "DELETE") {
			$params["noSuratKontrol"] = !empty($params["noSurat"]) ? $params["noSurat"] : "";
			unset($params["noSurat"]);
		}
		
		$params = $method != "DELETE" ? $params : [
			"t_suratkontrol" => $params
		];

		$data = json_encode([
			"request" => $params
		]);

		$uris = [
			1 => [
				"POST" => "RencanaKontrol/InsertSPRI",
				"PUT"  => "RencanaKontrol/UpdateSPRI",
				"DELETE" => "RencanaKontrol/Delete"
			],
			2 => [
				"POST" => "RencanaKontrol/insert",
				"PUT"  => "RencanaKontrol/Update",
				"DELETE" => "RencanaKontrol/Delete"
			]
		];
		
		$result =  json_decode($this->sendRequest($uris[$jns][$method], $method, $data, "application/x-www-form-urlencoded"));		
		if($result) {
			$message = trim($result->metadata->message);
			$result->metadata->requestId = $this->config["koders"];			
			if($result->metadata->code == 200) {
				if($method == "DELETE") $prms["status"] = 0;
				else $prms["noSurat"] = ($jns == 2 ? $result->response->noSuratKontrol : $result->response->noSPRI);
				$this->store->simpanData($prms, $method == "POST", false);
			} else {
				if($result->metadata != null) {
					$message = $result->metadata->code."-".$message;
				}
			}
		} else {
			return json_decode(json_encode([
				'metadata' => [
					'message' => "SIMRSInfo::Error Request Service - Rencana Kontrol <br/>".$this::RESULT_IS_NULL,
					'code' => 502,
					'requestId'=> $this->config["koders"]
				]
			]));
		}
		
		return $result;
	}

	/* Rencana Kontrol>>>Cari SEP
	 * Melihat data SEP untuk keperluan rencana kontrol
	 * @parameter 
	 *   $params string | ["nomor" => value]
	 *   $uri string
	 */
	function cariSEP($params, $uri = "RencanaKontrol/nosep/") {
		$nomor = $params;
		if(is_array($params)) {
			if(isset($params["nomor"])) $nomor = $params["nomor"];
		}
		
		$result = Json::decode($this->sendRequest($uri.$nomor));
		if($result) $result->metadata->requestId = $this->config["koders"];
		else {
			return json_decode(json_encode([
				'metadata' => [
					'message' => "SIMRSInfo::Error Request Service - Cari Sep di Rencana Kontrol <br/>".$this::RESULT_IS_NULL,
					'code' => 502,
					'requestId'=> $this->config["koders"]
				]
			]));
		}
		return $result;
	}

	/* Rencana Kontrol>>>Cari Nomor Surat Kontrol
	 * Melihat data SEP untuk keperluan rencana kontrol
	 * @parameter 
	 *   $params string | ["nomor" => value]
	 *   $uri string
	 */
	function cariNomorSurat($params, $uri = "RencanaKontrol/noSuratKontrol/") {
		$nomor = $params;
		if(is_array($params)) {
			if(isset($params["nomor"])) $nomor = $params["nomor"];
		}
		
		$result = Json::decode($this->sendRequest($uri.$nomor));
		if($result) $result->metadata->requestId = $this->config["koders"];
		else {
			return json_decode(json_encode([
				'metadata' => [
					'message' => "SIMRSInfo::Error Request Service - Cari Nomor Surat Kontrol <br/>".$this::RESULT_IS_NULL,
					'code' => 502,
					'requestId'=> $this->config["koders"]
				]
			]));
		}
		return $result;
	}

	/* Rencana Kontrol>>>Data Nomor Surat Kontrol
	 * Data Rencana Kontrol
	 * @parameter 
	 *   $params [ 
	 *       "tglAwal" => value, | yyyy-MM-dd
	 *       "tglAkhir" => value, | yyyy-MM-dd
	 *       "filter" => value | 1 = tanggal entri, 2 = tanggal rencana kontrol
	 *   ],
	 *   $uri string
	 */
	function list($params, $uri = "RencanaKontrol/ListRencanaKontrol/") {
	    $tglAwal = $tglAkhir = date("Y-m-d");
	    $filter = 2;
	    if(is_array($params)) {
	        if(isset($params["tglAwal"])) $tglAwal = $params["tglAwal"];
			if(isset($params["tglAkhir"])) $tglAkhir = $params["tglAkhir"];
	        if(isset($params["filter"])) $faskes = $params["filter"];      
	    }

		$result = Json::decode($this->sendRequest($uri."tglAwal/".$tglAwal."/tglAkhir/".$tglAkhir."/filter/".$filter));
	    if($result) {
	        $result->metadata->requestId = $this->config["koders"];
	        if($result->response) {
	            $data = isset($result->response->list) ? (array) $result->response->list : [];
				$result->response->list = [];
				if(isset($params["noKartu"])) {
					foreach($data as $d) {
						if($d->noKartu == $params["noKartu"]) {
							$result->response->list[] = $d;
						}
					}
				} else {
	            	$result->response->list = $data;
				}

				foreach($result->response->list as $l) {
					$data = is_array($l) ? $l : (array) $l;
					$finds = $this->store->load([
						"noSurat" => $data["noSuratKontrol"]
					]);
					if(count($finds) == 0) $this->store->simpanData([
						"noSurat" => $data["noSuratKontrol"],
						"jnsKontrol" => $data["jnsKontrol"],
						"nomor" => $data["jnsKontrol"] == 1 ? $data["noKartu"] : $data["noSepAsalKontrol"],
						"tglRencanaKontrol" => $data["tglRencanaKontrol"],
						"kodeDokter" => $data["kodeDokter"],
						"poliKontrol" => $data["poliTujuan"]
					], true, false);
				}
	            $result->response->count = count($data);
	        }
	    } else {
	        return json_decode(json_encode([
	            'metadata' => [
	                'message' => "SIMRSInfo::Error Request Service - Data Nomor Surat Kontrol <br/>".$this::RESULT_IS_NULL,
	                'code' => 502,
	                'requestId'=> $this->config["koders"]
				]
			]));
	    }
	    return $result;
	}

	/* Rencana Kontrol>>>Data Poli/Spesialistik
	 * Data Rencana Kontrol
	 * @parameter 
	 *   $params [ 
	 *       "jenisKontrol" => value, | 1 = SPRI, 2 = Rencana Kontrol
	 *       "nomor" => value, | jenisKontrol = 1 maka di isi nomor kartu, jika jenis kontrol 2 maka di isi nomor sep
	 *       "tglRencanaKontrol" => value | yyyy-MM-dd
	 *   ],
	 *   $uri string
	 */
	function dataPoli($params, $uri = "RencanaKontrol/ListSpesialistik/") {
	    $jenisKontrol = 1;
	    $nomor = "0";
		$tgl = date("Y-m-d");
	    if(is_array($params)) {
	        if(isset($params["jenisKontrol"])) $jenisKontrol = $params["jenisKontrol"];
			if(isset($params["nomor"])) $nomor = empty($params["nomor"]) ? "0000000000000" : $params["nomor"];
	        if(isset($params["tglRencanaKontrol"])) $tgl = $params["tglRencanaKontrol"];      
	    }

		$result = Json::decode($this->sendRequest($uri."JnsKontrol/".$jenisKontrol."/nomor/".$nomor."/TglRencanaKontrol/".$tgl));
	    if($result) {
	        $result->metadata->requestId = $this->config["koders"];
	        if($result->response) {
	            $data = isset($result->response->list) ? (array) $result->response->list : [];
	            $result->response->list = $data;
	            $result->response->count = count($data);
	        }
	    } else {
	        return json_decode(json_encode([
	            'metadata' => [
	                'message' => "SIMRSInfo::Error Request Service - Data Poli/Spesialistik <br/>".$this::RESULT_IS_NULL,
	                'code' => 502,
	                'requestId'=> $this->config["koders"]
				]
			]));
	    }
	    return $result;
	}

	/* Rencana Kontrol>>>Data Dokter
	 * Data Rencana Kontrol
	 * @parameter 
	 *   $params [ 
	 *       "jenisKontrol" => value, | 1 = SPRI, 2 = Rencana Kontrol
	 *       "kodePoli" => value,
	 *       "tglRencanaKontrol" => value | yyyy-MM-dd
	 *   ],
	 *   $uri string
	 */
	function dataDokter($params, $uri = "RencanaKontrol/JadwalPraktekDokter/") {
	    $jenisKontrol = 1;
	    $kode = "";
		$tgl = date("Y-m-d");
	    if(is_array($params)) {
	        if(isset($params["jenisKontrol"])) $jenisKontrol = $params["jenisKontrol"];
			$kode = empty($params["kodePoli"]) ? "XXX" : $params["kodePoli"];
	        if(isset($params["tglRencanaKontrol"])) $tgl = $params["tglRencanaKontrol"];      
	    }

		$result = Json::decode($this->sendRequest($uri."JnsKontrol/".$jenisKontrol."/KdPoli/".$kode."/TglRencanaKontrol/".$tgl));
	    if($result) {
	        $result->metadata->requestId = $this->config["koders"];
	        if($result->response) {
	            $data = isset($result->response->list) ? (array) $result->response->list : [];
	            $result->response->list = $data;
	            $result->response->count = count($data);
	        }
	    } else {
	        return json_decode(json_encode([
	            'metadata' => [
	                'message' => "SIMRSInfo::Error Request Service - Data Dokter <br/>".$this::RESULT_IS_NULL,
	                'code' => 502,
	                'requestId'=> $this->config["koders"]
				]
			]));
	    }
	    return $result;
	}
}