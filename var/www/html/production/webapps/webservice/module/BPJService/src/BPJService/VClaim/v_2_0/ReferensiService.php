<?php
/**
 * BPJService
 * @author hariansyah
 * 
 */
 
namespace BPJService\VClaim\v_2_0;

use BPJService\VClaim\v_1_1\Service as BaseService;
use Laminas\Json\Json;

class ReferensiService extends BaseService {
	function __construct($config) {
		parent::__construct($config);
	}

	protected function sendRequest($action = "", $method = "GET", $data = "", $contenType = "application/json", $url = "") {
		$result = parent::sendRequest($action, $method, $data, $contenType, $url);
		$result = Json::decode($result);
		if(is_object($result)) if($result->response) $result->response = $this->decrypt($result->response);
		return Json::encode($result);
	}

	/* Referensi>>>Diagnosa Program PRB
	 * @parameter 
	 *   $uri string
	 */
	function diagnosaPrb($uri = "referensi/diagnosaprb") {
		$result = Json::decode($this->sendRequest($uri));
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
	                'message' => "SIMRSInfo::Error Request Service - Diagnosa Program PRB<br/>".$this::RESULT_IS_NULL,
	                'code' => 502,
	                'requestId'=> $this->config["koders"]
				]
			]));
	    }
	    return $result;
	}

	/* Referensi>>>Obat Generik Program PRB
	 * @parameter 
	 *   $params [ 
	 *       "nama" => value	 
	 *   ],
	 *   $uri string
	 */
	function obatGenerikPrb($params, $uri = "referensi/obatprb/") {
	    $nama = $params;		
	    if(is_array($params)) if(isset($params["nama"])) $nama = $params["nama"];

		$result = Json::decode($this->sendRequest($uri.$nama));
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
	                'message' => "SIMRSInfo::Error Request Service - Obat Generik Program PRB<br/>".$this::RESULT_IS_NULL,
	                'code' => 502,
	                'requestId'=> $this->config["koders"]
				]
			]));
	    }
	    return $result;
	}
}