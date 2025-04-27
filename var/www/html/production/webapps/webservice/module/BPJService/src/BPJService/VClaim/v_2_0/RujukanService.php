<?php
/**
 * BPJService
 * @author hariansyah
 * 
 */
 
namespace BPJService\VClaim\v_2_0;

use BPJService\VClaim\v_1_1\Service as BaseService;
use Laminas\Json\Json;
use BPJService\db\rujukan\khusus\Service as RujukanKhusus;
use BPJService\db\rujukan\masuk\Service as RujukanMasuk;

class RujukanService extends BaseService {
	private $khusus;
	private $masuk;

	function __construct($config) {
		parent::__construct($config);

		$this->khusus = new RujukanKhusus();
		$this->masuk = new RujukanMasuk();
	}

	protected function sendRequest($action = "", $method = "GET", $data = "", $contenType = "application/json", $url = "") {
		$result = parent::sendRequest($action, $method, $data, $contenType, $url);
		$result = Json::decode($result);
		if(is_object($result)) if($result->response) $result->response = $this->decrypt($result->response);
		return Json::encode($result);
	}

	/* Rujukan>>>Insert Rujukan
	 * @parameter 
	 *   $params array(
	 *		"noSep" => value,
	 *		"tglRujukan" => value, | yyyy-MM-dd
	 *		"tglRencanaKunjungan" => value, | yyyy-MM-dd		#NEW VClaim 2.0
	 *		"ppkDirujuk" => value
	 *		"jnsPelayanan" => value, | 1 (Rawat Inap), 2 (Rawat Jalan)
	 *		"catatan" => value,
	 *		"diagRujukan" => value, | kode diagnosa ICD-10
	 *		"tipeRujukan" => value, | tipe rujukan -> 0.penuh, 1.Partial 2.rujuk balik
	 *		"poliRujukan" => value, | kode poli rujukan -> data di referensi poli
	 *		"user" => value,
	 *  )
	 *   $uri string
	 */
	function insertRujukan($params, $uri = "Rujukan/2.0/insert") {
		if(isset($params["jnsPelayanan"])) $params["jnsPelayanan"] = strval($params["jnsPelayanan"]);
		if(isset($params["tipeRujukan"])) $params["tipeRujukan"] = strval($params["tipeRujukan"]);
		if(isset($params["tglRujukan"])) $params["tglRujukan"] = substr($params["tglRujukan"], 0, 10);
		if(isset($params["tglRencanaKunjungan"])) $params["tglRencanaKunjungan"] = substr($params["tglRencanaKunjungan"], 0, 10);
		
		$data = json_encode([
			"request" => [
				"t_rujukan" => $params
			]
		]);
		
		$result =  json_decode($this->sendRequest($uri, "POST", $data, "application/x-www-form-urlencoded"));		
		if($result) {
			$message = trim($result->metadata->message);
			$result->metadata->requestId = $this->config["koders"];			
			if($result->metadata->code == 200) {
				$params["noRujukan"] = $params["noSep"];
				if($params["tipeRujukan"] != 1) {
					$params["noRujukan"] = $result->response->rujukan->noRujukan;
					$params["tglBerlakuKunjungan"] = $result->response->rujukan->tglBerlakuKunjungan;
				}
				$rRujukan = $this->rujukan->load([
					"noSep" => $params["noSep"],
					"status" => 1
				]);
				
				$this->rujukan->simpan($params, count($rRujukan) == 0);
			} else {
				if($result->metadata != null) {
					$message = $result->metadata->code."-".$message;
				}
			}
		} else {
			return json_decode(json_encode([
				'metadata' => [
					'message' => "SIMRSInfo::Error Request Service - Insert Rujukan<br/>".$this::RESULT_IS_NULL,
					'code' => 502,
					'requestId'=> $this->config["koders"]
				]
			]));
		}
		
		return $result;
	}

	/* Rujukan>>>Update Rujukan
	 * @parameter 
	 *   $params array(
	 *		"noSep" || "noRujukan" => value,
	 *		"tglRujukan" => value, | yyyy-MM-dd					#NEW VClaim 2.0
	 *		"tglRencanaKunjungan" => value, | yyyy-MM-dd		#NEW VClaim 2.0
	 *		"ppkDirujuk" => value
	 *		"jnsPelayanan" => value, | 1 (Rawat Inap), 2 (Rawat Jalan)
	 *		"catatan" => value,
	 *		"diagRujukan" => value, | kode diagnosa ICD-10
	 *		"tipeRujukan" => value, | tipe rujukan -> 0.penuh, 1.Partial 2.rujuk balik
	 *		"poliRujukan" => value, | kode poli rujukan -> data di referensi poli
	 *		"user" => value,
	 *  )
	 *   $uri string
	 */
	function updateRujukan($params, $uri = "Rujukan/2.0/Update") {
		$noSep = isset($params["noSep"]) ? $params["noSep"] : "";
		if(isset($params["jnsPelayanan"])) $params["jnsPelayanan"] = strval($params["jnsPelayanan"]);
		if(isset($params["tipeRujukan"])) $params["tipeRujukan"] = strval($params["tipeRujukan"]);
		if(isset($params["tglRujukan"])) $params["tglRujukan"] = substr($params["tglRujukan"], 0, 10);
		if(isset($params["tglRencanaKunjungan"])) $params["tglRencanaKunjungan"] = substr($params["tglRencanaKunjungan"], 0, 10);
		
		if(!isset($params["noRujukan"])) {
			if($noSep != "") {
				$rRujukan = $this->rujukan->load([
					"noSep" => $noSep,
					"status" => 1
				]);
				$params["noRujukan"] = $noSep;
				if(count($rRujukan) > 0) {
					$params["noRujukan"] = $rRujukan[0]["noRujukan"];					
				}
			}
		}
		if($noSep != "") unset($params["noSep"]);
		
		$data = json_encode([
			"request" => [
				"t_rujukan" => $params
			]
		]);			
		
		$result =  json_decode($this->sendRequest($uri, "PUT", $data, "application/x-www-form-urlencoded"));		
		if($result) {
			$message = trim($result->metadata->message);
			$result->metadata->requestId = $this->config["koders"];			
			if($result->metadata->code == 200) {
				if($params["tipeRujukan"] != 1) $params["tglBerlakuKunjungan"] = $result->response->rujukan->tglBerlakuKunjungan;
				$rRujukan = $this->rujukan->load([
					"noRujukan" => $params["noRujukan"],
					"status" => 1
				]);
				
				$this->rujukan->simpan($params, count($rRujukan) == 0);
			} else {
				if($result->metadata != null) {
					$message = $result->metadata->code."-".$message;
				}
			}
		} else {
			return json_decode(json_encode([
				'metadata' => [
					'message' => "SIMRSInfo::Error Request Service - Update Rujukan<br/>".$this::RESULT_IS_NULL,
					'code' => 502,
					'requestId'=> $this->config["koders"]
				]
			]));
		}
		
		return $result;
	}

	/* Rujukan>>>List Spesialistik Rujukan
	 * @parameter 
	 *   $params [ 
	 *       "ppkRujukan" => value | Kode
	 *       , "tglRujukan" => value | yyyy-MM-dd
	 *   ],
	 *   $uri string
	 */
	function listSpesialistikRujukan($params, $uri = "Rujukan/ListSpesialistik") {
	    $ppk = "/"."PPKRujukan/";
		$tgl = "/"."TglRujukan/";
	    if(is_array($params)) {
			$ppk .= !empty($params["ppkRujukan"]) ? $params["ppkRujukan"] : "0";
			$tgl .= !empty($params["tglRujukan"]) ? $params["tglRujukan"] : date("Y-m-d");
	    } else {
			$ppk .= "0";
			$tgl .= date("Y-m-d");
		}

		$result = Json::decode($this->sendRequest($uri.$ppk.$tgl));
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
	                'message' => "SIMRSInfo::Error Request Service - List Spesialistik Rujukan<br/>".$this::RESULT_IS_NULL,
	                'code' => 502,
	                'requestId'=> $this->config["koders"]
				]
			]));
	    }
	    return $result;
	}

	/* Rujukan>>>List Sarana
	 * @parameter 
	 *   $params [ 
	 *       "ppkRujukan" => value | Kode 8 digit
	 *   ],
	 *   $uri string
	 */
	function listSarana($params, $uri = "Rujukan/ListSarana") {
	    $ppk = "/"."PPKRujukan/";
	    if(is_array($params)) {
			if(isset($params["ppkRujukan"])) $ppk .= $params["ppkRujukan"];
	    }

		$result = Json::decode($this->sendRequest($uri.$ppk));
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
	                'message' => "SIMRSInfo::Error Request Service - List Sarana<br/>".$this::RESULT_IS_NULL,
	                'code' => 502,
	                'requestId'=> $this->config["koders"]
				]
			]));
	    }
	    return $result;
	}

	/** Rujukan>>>Insert Rujukan Khusus
	 * @param 
	 *   $params array(
	 *		"noRujukan" => value,
	 *		"diagnosa" => value, | array [ "kode": "P;N18" ], [ "kode": "S;N18" ] (P = Primary; S = Sekunder; N18 = ICD10)
	 *		"procedure" => value, | array [ "kode" : "39.95" ]
	 *		"user" => value
	 *  )
	 *   $uri string
	 */
	function insertRujukanKhusus($params, $uri = "Rujukan/Khusus/insert") {
		if(empty($params["noRujukan"])) return json_decode(json_encode([
			'metadata' => [
				'message' => "noRujukan tidak boleh kosong",
				'code' => 412,
				'requestId'=> $this->config["koders"]
			]
		]));
		if(empty($params["diagnosa"])) return json_decode(json_encode([
			'metadata' => [
				'message' => "diagnosa tidak boleh kosong",
				'code' => 412,
				'requestId'=> $this->config["koders"]
			]
		]));
		if(empty($params["user"])) return json_decode(json_encode([
			'metadata' => [
				'message' => "user tidak boleh kosong",
				'code' => 412,
				'requestId'=> $this->config["koders"]
			]
		]));
		
		$data = json_encode($params);
		
		$result =  json_decode($this->sendRequest($uri, "POST", $data, "application/x-www-form-urlencoded"));		
		if($result) {
			$message = trim($result->metadata->message);
			$result->metadata->requestId = $this->config["koders"];			
			if($result->metadata->code == 200) {
				$params["tglrujukan_awal"] = $result->response->rujukan->tglrujukan_awal;
				$params["tglrujukan_berakhir"] = $result->response->rujukan->tglrujukan_berakhir;
				$rRujukan = $this->khusus->load([
					"noRujukan" => $params["noRujukan"]
				]);
				
				$this->khusus->simpanData($params, count($rRujukan) == 0);
			} else {
				if($result->metadata != null) {
					$message = $result->metadata->code."-".$message;
				}
			}
		} else {
			return json_decode(json_encode([
				'metadata' => [
					'message' => "SIMRSInfo::Error Request Service - Insert Rujukan Khusus<br/>".$this::RESULT_IS_NULL,
					'code' => 502,
					'requestId'=> $this->config["koders"]
				]
			]));
		}
		
		return $result;
	}

	/** Rujukan>>>Delete Rujukan Khusus
	 * @param 
	 *   $params array(
	 *		"idRujukan" => value,
	 *		"noRujukan" => value,
	 *		"user" => value
	 *  )
	 *   $uri string
	 */
	function deleteRujukanKhusus($params, $uri = "Rujukan/Khusus/delete") {
		if(empty($params["idRujukan"])) return json_decode(json_encode([
			'metadata' => [
				'message' => "idRujukan tidak boleh kosong",
				'code' => 412,
				'requestId'=> $this->config["koders"]
			]
		]));
		if(empty($params["noRujukan"])) return json_decode(json_encode([
			'metadata' => [
				'message' => "noRujukan tidak boleh kosong",
				'code' => 412,
				'requestId'=> $this->config["koders"]
			]
		]));
		if(empty($params["user"])) return json_decode(json_encode([
			'metadata' => [
				'message' => "user tidak boleh kosong",
				'code' => 412,
				'requestId'=> $this->config["koders"]
			]
		]));
		
		$data = json_encode([
			"request" => [
				"t_rujukan" => $params
			]
		]);
		
		$result =  json_decode($this->sendRequest($uri, "POST", $data, "application/x-www-form-urlencoded"));		
		if($result) {
			$message = trim($result->metadata->message);
			$result->metadata->requestId = $this->config["koders"];			
			if($result->metadata->code == 200) {
				$params["status"] = 0;
				$this->khusus->simpanData($params);
			} else {
				if($result->metadata != null) {
					$message = $result->metadata->code."-".$message;
				}
			}
		} else {
			return json_decode(json_encode([
				'metadata' => [
					'message' => "SIMRSInfo::Error Request Service - Delete Rujukan Khusus<br/>".$this::RESULT_IS_NULL,
					'code' => 502,
					'requestId'=> $this->config["koders"]
				]
			]));
		}
		
		return $result;
	}

	/* Rujukan>>>List Rujukan Khusus
	 * @parameter 
	 *   $params [ 
	 *       "bulan" => value | (1,2,3,4,5,6,7,8,9,10,11,12)
	 *       , "tahun" => value | 4 digit
	 *   ],
	 *   $uri string
	 */
	function listRujukanKhusus($params, $uri = "Rujukan/Khusus/List") {
	    $bln = "/"."Bulan/";
		$thn = "/"."Tahun/";
	    if(is_array($params)) {
			$bln .= !empty($params["bulan"]) ? $params["bulan"] : date("m");
			$thn .= !empty($params["tahun"]) ? $params["tahun"] : date("Y");
	    }

		$result = Json::decode($this->sendRequest($uri.$bln.$thn));
	    if($result) {
	        $result->metadata->requestId = $this->config["koders"];
	        if($result->response) {
	            $data = isset($result->response->rujukan) ? (array) $result->response->rujukan : [];
	            $result->response->list = $data;
	            $result->response->count = count($data);
	        }
	    } else {
	        return json_decode(json_encode([
	            'metadata' => [
	                'message' => "SIMRSInfo::Error Request Service - List Rujukan Khusus<br/>".$this::RESULT_IS_NULL,
	                'code' => 502,
	                'requestId'=> $this->config["koders"]
				]
			]));
	    }
	    return $result;
	}

	/* Rujukan>>>Data Rujukan Masuk by Nomor Rujukan
	 * cari data rujukan berdasarkan Nomor rujukan
	 * @parameter 
	 *   $params string | array("nomor" => value)
	 *   $uri string
	 */
	function cariRujukanDgnNoRujukan($params, $uri = "Rujukan/") {
		$result = parent::cariRujukanDgnNoRujukan($params, $uri);
		if($result) {
			if($result->response) {
				if($result->response->rujukan) $this->simpanRujukanMasuk($result->response->rujukan);
			}
		}
		return $result;
	}
	
	/* Rujukan>>>Data Rujukan Masuk Berdasarkan Nomor kartu
	 * cari data rujukan masuk berdasarkan Nomor Kartu BPJS
	 * @parameter 
	 *   $params string | array("noKartu" => value)
	 *   $uri string
	 */
	function cariRujukanDgnNoKartuBPJS($params, $uri = "Rujukan/") {
		$result = parent::cariRujukanDgnNoKartuBPJS($params, $uri);
		if($result) {
			if($result->response) {
				if($result->response->rujukan) $this->simpanRujukanMasuk($result->response->rujukan);
			}
		}
		return $result;
	}

	/* Rujukan>>>Data Rujukan Masuk Berdasarkan Nomor Kartu (Multi Record)
	 * cari data rujukan masuk berdasarkan Nomor Kartu BPJS (Multi Record)
	 * @parameter 
	 *   $params string | array("noKartu" => value, "faskes" => value | 1 = Faskes 1; 2 = Faskes 2/RS )
	 *   $uri string
	 */
	function listRujukanDgnNoKartuBPJS($params, $uri = "Rujukan/") {
		$result = parent::listRujukanDgnNoKartuBPJS($params, $uri);
	    if($result) {
			if($result->response) {
				$data = isset($result->response->rujukan) ? (array) $result->response->rujukan : [];
				foreach($data as $d) {
					$this->simpanRujukanMasuk($d);
				}
			}
		}
	    return $result;
	}

	private function simpanRujukanMasuk($rujukan) {
		if($rujukan) {
			$rujukan = (array) $rujukan;
			
			$peserta = $rujukan["peserta"];
			if(is_object($peserta)) $peserta = (array) $peserta;
			if(is_string($peserta)) $peserta = (array) json_decode($peserta);
			
			$finds = $this->masuk->load([
				"noKunjungan" => $rujukan["noKunjungan"]
			]);

			$this->masuk->simpanData([
				"noKunjungan" => $rujukan["noKunjungan"],
				"noKartu" => $peserta["noKartu"],
				"tglKunjungan" => $rujukan["tglKunjungan"],
				"provPerujuk" => is_array($rujukan["provPerujuk"]) || is_object($rujukan["provPerujuk"]) ? json_encode($rujukan["provPerujuk"]) : $rujukan["provPerujuk"],
				"diagnosa" => is_array($rujukan["diagnosa"]) || is_object($rujukan["diagnosa"]) ? json_encode($rujukan["diagnosa"]) : $rujukan["diagnosa"],
				"keluhan" => $rujukan["keluhan"],
				"poliRujukan" => is_array($rujukan["poliRujukan"]) || is_object($rujukan["poliRujukan"]) ? json_encode($rujukan["poliRujukan"]) : $rujukan["poliRujukan"],
				"pelayanan" => is_array($rujukan["pelayanan"]) || is_object($rujukan["pelayanan"]) ? json_encode($rujukan["pelayanan"]) : $rujukan["pelayanan"]
			], count($finds) == 0, false);
		}
	}
}