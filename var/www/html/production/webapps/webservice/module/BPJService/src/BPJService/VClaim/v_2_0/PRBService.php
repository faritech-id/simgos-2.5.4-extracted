<?php
/**
 * BPJService
 * @author hariansyah
 * 
 */
 
namespace BPJService\VClaim\v_2_0;

use BPJService\VClaim\v_1_1\Service as BaseService;
use Laminas\Json\Json;
use BPJService\db\prb\Service as PRBStore;

class PRBService extends BaseService {
	protected $store;

	function __construct($config) {
		parent::__construct($config);

		$this->store = new PRBStore();
	}

	protected function sendRequest($action = "", $method = "GET", $data = "", $contenType = "application/json", $url = "") {
		$result = parent::sendRequest($action, $method, $data, $contenType, $url);
		$result = Json::decode($result);
		if(is_object($result)) if($result->response) $result->response = $this->decrypt($result->response);
		return Json::encode($result);
	}

	/** Program Rujuk Balik (PRB)
	 * Insert / Update / Delete
	 * @parameter 
	 *   $method default POST
	 *   $params [
	 *      "noSRB" => value,						-		PUT		DELETE
	 *      "noSep" => value,						POST	PUT		-		
	 *      "noKartu" => value,						POST	PUT		-
	 *	    "alamat" => value, | noSEP & noKartu	POST	PUT		-
	 *		"email" => value,						POST	PUT		-
	 *		"programPRB" => value,					POST	PUT		-
	 *		"kodeDPJP" => value,					POST	PUT		-
	 *		"keterangan" => value,					POST	PUT		-
	 *		"saran" => value,						POST	PUT		-
	 *		"user" => value,						POST	PUT		DELETE
	 *		"obat" => [[							POST
	 *			"kdObat" => value,
	 *			"signa1" => value,
	 *			"signa2" => value,
	 *			"jmlObat" => value
	 *      ]]
	 *   	 
	 */
	function prb($method = "POST", $params) {
		$params = $method != "DELETE" ? $params : [
			"t_prb" => $params
		];

		$data = json_encode([
			"request" => $params
		]);

		$uris = [
			"POST" => "PRB/insert",
			"PUT"  => "PRB/Update",
			"DELETE" => "PRB/Delete"
		];
		
		$result =  json_decode($this->sendRequest($uris[$method], "POST", $data, "application/x-www-form-urlencoded"));		
		if($result) {
			$message = trim($result->metadata->message);
			$result->metadata->requestId = $this->config["koders"];			
			if($result->metadata->code == 200) {
				if($method == "DELETE") $params["status"] = 0; 
				else {
					$params["noSRB"] = $result->response->noSRB;
					$params["tglSRB"] = $result->response->tglSRB;
					$params["obat"] = json_encode($params["obat"]);
				}
				$this->store->simpanData($params, $method == "POST", false);
			} else {
				if($result->metadata != null) {
					$message = $result->metadata->code."-".$message;
				}
			}
		} else {
			return json_decode(json_encode([
				'metadata' => [
					'message' => "SIMRSInfo::Error Request Service - Pembuatan Rujuk Balik (PRB)<br/>".$this::RESULT_IS_NULL,
					'code' => 502,
					'requestId'=> $this->config["koders"]
				]
			]));
		}
		
		return $result;
	}

	/**
	 *  PRB>>>Nomor SRB
	 * @method cariSRBBerdasarkanNomor
	 * Pencarian data PRB (Rujuk Balik) Berdasarkan Nomor SRB
	 * @parameter 
	 *   $params [ 
	 *       "nomor" => value | Nomor SRB Peserta
	 *       , "noSEP" => value
	 *   ],
	 *   $uri string
	 */
	function cariSRBBerdasarkanNomor($params, $uri = "prb") {
		$nomor = "/";
		$sep = "/"."nosep/";
	    if(is_array($params)) {
			if(isset($params["nomor"])) $nomor .= $params["nomor"];
			if(isset($params["noSEP"])) $sep .= $params["noSEP"];
	    }

		$result = Json::decode($this->sendRequest($uri.$nomor.$sep));
		if($result) {
			$result->metadata->requestId = $this->config["koders"];
		} else {
			return json_decode(json_encode([
				'metadata' => [
					'message' => "SIMRSInfo::Error Request Service - Pencarian Data PRB berdasarkan Nomor SRB<br/>".$this::RESULT_IS_NULL,
					'code' => 502,
					'requestId'=> $this->config["koders"]
				]
			]));
		}
		return $result;
	}

	/** 
	 * PRB>>>Tanggal SRB
	 * @method cariSRBBerdasarkanTanggal
	 * Pencarian data PRB (Rujuk Balik) Berdasarkan Tanggal SRB
	 * @parameter 
	 *   $params [ 
	 *       "tglMulai" => value | yyyy-MM-dd
	 *       , "tglAkhir" => value | yyyy-MM-dd
	 *   ],
	 *   $uri string
	 */
	function cariSRBBerdasarkanTanggal($params, $uri = "prb") {
		$mulai = "/"."tglMulai/";
		$akhir = "/"."tglAkhir/";
	    if(is_array($params)) {
			if(isset($params["tglMulai"])) $mulai .= $params["tglMulai"];
			if(isset($params["tglAkhir"])) $akhir .= $params["tglAkhir"];
	    }

		$result = Json::decode($this->sendRequest($uri.$mulai.$akhir));
		if($result) {
			$result->metadata->requestId = $this->config["koders"];
	        if($result->response) {
	            $data = isset($result->response->prb->list) ? (array) $result->response->prb->list : [];
	            $result->response->list = $data;
	            $result->response->count = count($data);
	        }
		} else {
			return json_decode(json_encode([
				'metadata' => [
					'message' => "SIMRSInfo::Error Request Service - Pencarian Data PRB berdasarkan Tanggal SRB<br/>".$this::RESULT_IS_NULL,
					'code' => 502,
					'requestId'=> $this->config["koders"]
				]
			]));
		}
		return $result;
	}
}