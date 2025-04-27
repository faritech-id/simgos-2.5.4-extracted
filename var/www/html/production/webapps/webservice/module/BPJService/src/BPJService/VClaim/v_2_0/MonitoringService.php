<?php
/**
 * BPJService
 * @author hariansyah
 * 
 */
 
namespace BPJService\VClaim\v_2_0;

use BPJService\VClaim\v_1_1\Service as BaseService;
use Laminas\Json\Json;
use BPJService\db\kunjungan\Service as KunjunganService;

class MonitoringService extends BaseService {
	protected $kunjungan;

	function __construct($config) {
		parent::__construct($config);
		$this->kunjungan = new KunjunganService();
	}

	protected function sendRequest($action = "", $method = "GET", $data = "", $contenType = "application/json", $url = "") {
		$result = parent::sendRequest($action, $method, $data, $contenType, $url);
		$result = Json::decode($result);
		if(is_object($result)) if($result->response) $result->response = $this->decrypt($result->response);
		return Json::encode($result);
	}

	/* Monitoring>>>Data Kunjungan
	 * Data Kunjungan
	 * @parameter 
	 *   $params array(
	 *		"tanggal" => value | yyyy-MM-dd,
	 *		"jenis" => value,
	 *)
	 *   $uri string
	 */
	function monitoringKunjungan($params, $uri = "Monitoring/Kunjungan/") {
		$tanggal = $jenis = "";
		if(is_array($params)) {
			if(isset($params["tanggal"])) $tanggal = "Tanggal/".$params["tanggal"]."/";
			if(isset($params["jenis"])) $jenis = "JnsPelayanan/".$params["jenis"];
		}
		$result = json_decode($this->sendRequest($uri.$tanggal.$jenis));
		if($result) {
			$result->metadata->requestId = $this->config["koders"];			
			if($result->response) {
				$list = isset($result->response->sep) ? (array) $result->response->sep : array();				
				$result->response->list = $list;
				$result->response->count = count($list);
				foreach($list as $l) {
					$data = is_array($l) ? $l : (array) $l;
					$finds = $this->kunjungan->load([
						"noSEP" => $data["noSep"]
					]);
					if(count($finds) == 0) $this->kunjungan->simpan([
						"noKartu" => $data["noKartu"],
						"noSEP" => $data["noSep"],
						"tglSEP" => $data["tglSep"],
						"poliTujuan" => $data["poli"],
						"noRujukan" => $data["noRujukan"],
						"diagAwal" => $data["diagnosa"],
						"jenisPelayanan" => $data["jnsPelayanan"] == "R.Jalan" ? 2 : 1,
					], true, false);
				}
				unset($result->response->sep);
			}
		} else {
			return json_decode(json_encode(array(			
				'metadata' => array(
					'message' => "SIMRSInfo::Error Request Service - Monitoring Data Kunjungan<br/>".$this::RESULT_IS_NULL,
					'code' => 502,
					'requestId'=> $this->config["koders"]
				)
			)));
		}
		return $result;
	}
}