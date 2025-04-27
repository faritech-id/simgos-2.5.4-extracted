<?php
namespace Kemkes\V2\Rpc\SITB;

use DBService\RPCResource;
use \DateTime;
use \DateTimeZone;
use Kemkes\db\sitb\pasien_tb\Service;

class SITBController extends RPCResource
{
	protected $title = "Pasien TB";

    public function __construct($controller) {        
        $this->authType = self::AUTH_TYPE_IP_OR_LOGIN;
        $this->service = new Service();
        
        $this->config = $controller->get('Config');
        $this->config = $this->config['services']['KemkesService'];
		$this->config = $this->config['SITB'];
    }

	protected function onBeforeSendRequest() {
		$this->headers = [
			"X-rs-id: ".$this->config["id"],
			"X-pass: ".$this->config["key"]
		];
        $dt = new DateTime(null, new DateTimeZone("UTC"));
	    $timestamp = $dt->getTimestamp();
	    $this->headers[] = "X-Timestamp: ".$timestamp;
	}
    
    /**
     * Create a new resource
     *
     * @param  mixed $data
     * @return mixed
     */
	public function create($data) {
	    $result = parent::create($data);
		return $result;
	}
	
	/**
	 * Update an existing resource
	 *
	 * @param  mixed $id
	 * @param  mixed $data
	 * @return mixed
	 */
	public function update($id, $data)
	{
		$data = is_object($data) ? (array) $data : $data;
		$data["kirim"] = 1;
	    $result = parent::update($id, $data);
		if($result["success"]){
			$return = $this->kirimAction($id);
			$status = [
				"gagal" => 1,
				"update gagal" => 1
			];
			if($status[$return["status"]]) {
				$this->response->setStatusCode(412);
				return [
					"success" => false,
					"status" => 412,
					"detail" => $return["keterangan"],
					"data" => null
				];
			}
		}
		return $result;
	}
		
	public function getList() {
	    $queries = (array) $this->request->getQuery();
	    $params = [];
		if(isset($queries["kirim"])) $params["kirim"] = $queries["kirim"];
	    if(isset($queries["limit"])) $params["limit"] = $queries["limit"];
	    if(isset($queries["start"])) $params["start"] = $queries["start"];
		if(isset($queries["sfinal"])) {
			if($queries["sfinal"] > -1) $params["final"] = $queries["sfinal"];
		}
	    if(isset($queries["nourut_pasien"])) $params["nourut_pasien"] = $queries["nourut_pasien"];
	    
	    $total = $this->service->getRowCount($params);
	    $data = [];
	    if($total > 0) $data = $this->service->load($params, ['*'], ["tanggal_buat_laporan DESC"]);
	    
	    return [
	        "status" => $total > 0 ? 200 : 404,
	        "success" => $total > 0 ? true : false,
	        "total" => $total,
	        "data" => $data,
	        "detail" => $total > 0 ? "SITB ditemukan" : "SITB tidak ditemukan"
	    ];
	}
	
	public function kirimAction($id = null) {
	    /* ambil data sitb */
	    $params = [
	        "start" => 0,
	        "limit" => 10
	    ];
	    $params[] = "kirim = 1";
		if(isset($id)) $params["id"] = $id;
	    
	    $froms = $this->service->load($params, ['*'], ['tanggal_updated ASC']);
		$result = null;
	    foreach($froms as &$row) {
	        $params = $row;
			$referensi = isset($params["REFERENSI"]) ? $params["REFERENSI"] : null;
	        
	        unset($params["id"]);
	        unset($params["tanggal_updated"]);
	        unset($params["oleh"]);
	        unset($params["kirim"]);
			unset($params["final"]);
			
			$params["jenis_kelamin"] = $params["jenis_kelamin"] == 1 ? "L" : "P";
			$tglLahir = explode("-", $params["tgl_lahir"]);
			$params["tgl_lahir"] = implode("", $tglLahir);
			if($params["klasifikasi_lokasi_anatomi"] == 0) unset($params["klasifikasi_lokasi_anatomi"]);
			if($params["klasifikasi_riwayat_pengobatan"] == 0) unset($params["klasifikasi_riwayat_pengobatan"]);
			if($params["tanggal_mulai_pengobatan"] == null) $params["tanggal_mulai_pengobatan"] = "";
			else {
				$tgl = explode(" ", $params["tanggal_mulai_pengobatan"]);
				$tgl = explode("-", $tgl[0]);
				$params["tanggal_mulai_pengobatan"] = implode("", $tgl);
			}
			if($params["paduan_oat"] == null) unset($params["paduan_oat"]);
			if($params["sebelum_pengobatan_hasil_mikroskopis"] == null) $params["sebelum_pengobatan_hasil_mikroskopis"] = "";
			else $this->setDeskripsiParamsValue($params, "sebelum_pengobatan_hasil_mikroskopis", $referensi);			
			
			if($params["sebelum_pengobatan_hasil_tes_cepat"] == null) $params["sebelum_pengobatan_hasil_tes_cepat"] = "";
			else $this->setDeskripsiParamsValue($params, "sebelum_pengobatan_hasil_tes_cepat", $referensi);
			
			if($params["sebelum_pengobatan_hasil_biakan"] == null) $params["sebelum_pengobatan_hasil_biakan"] = "";
			else $this->setDeskripsiParamsValue($params, "sebelum_pengobatan_hasil_biakan", $referensi);
			
			if($params["hasil_mikroskopis_bulan_2"] == null) $params["hasil_mikroskopis_bulan_2"] = "";
			if($params["hasil_mikroskopis_bulan_3"] == null) $params["hasil_mikroskopis_bulan_3"] = "";
			if($params["hasil_mikroskopis_bulan_5"] == null) $params["hasil_mikroskopis_bulan_5"] = "";			
			if($params["akhir_pengobatan_hasil_mikroskopis"] == null) $params["akhir_pengobatan_hasil_mikroskopis"] = "";
			else $this->setDeskripsiParamsValue($params, "akhir_pengobatan_hasil_mikroskopis", $referensi);
			
			if($params["tanggal_hasil_akhir_pengobatan"] == null) $params["tanggal_hasil_akhir_pengobatan"] = "";
			else {
				$tgl = explode("-", $params["tanggal_hasil_akhir_pengobatan"]);
				$params["tanggal_hasil_akhir_pengobatan"] = implode("", $tgl);
			}
			if($params["hasil_akhir_pengobatan"] == null) $params["hasil_akhir_pengobatan"] = "";
			else $this->setDeskripsiParamsValue($params, "hasil_akhir_pengobatan", $referensi);
			
			if($params["sumber_obat"] != null) $this->setDeskripsiParamsValue($params, "sumber_obat", $referensi);
			if($params["total_skoring_anak"] != null) $this->setDeskripsiParamsValue($params, "total_skoring_anak", $referensi);
			if($params["konfirmasiSkoring5"] != null) $this->setDeskripsiParamsValue($params, "konfirmasiSkoring5", $referensi);
			if($params["konfirmasiSkoring6"] != null) $this->setDeskripsiParamsValue($params, "konfirmasiSkoring6", $referensi);
			if($params["hasil_mikroskopis_bulan_2"] != null) $this->setDeskripsiParamsValue($params, "hasil_mikroskopis_bulan_2", $referensi);
			if($params["hasil_mikroskopis_bulan_3"] != null) $this->setDeskripsiParamsValue($params, "hasil_mikroskopis_bulan_3", $referensi);
			if($params["hasil_mikroskopis_bulan_5"] != null) $this->setDeskripsiParamsValue($params, "hasil_mikroskopis_bulan_5", $referensi);
			if($params["foto_toraks"] != null) $this->setDeskripsiParamsValue($params, "foto_toraks", $referensi);
			if($params["status_pengobatan"] != null) $this->setDeskripsiParamsValue($params, "status_pengobatan", $referensi);
			if($params["klasifikasi_status_hiv"] != null) $this->setDeskripsiParamsValue($params, "klasifikasi_status_hiv", $referensi);
			if($params["tanggal_dianjurkan_tes"] != null) {
				$tgl = explode("-", $params["tanggal_dianjurkan_tes"]);
				$params["tanggal_dianjurkan_tes"] = implode("", $tgl);
			}
			if($params["tanggal_tes_hiv"] != null) {
				$tgl = explode("-", $params["tanggal_tes_hiv"]);
				$params["tanggal_tes_hiv"] = implode("", $tgl);
			}
			if($params["hasil_tes_hiv"] != null) $this->setDeskripsiParamsValue($params, "hasil_tes_hiv", $referensi);
			if($params["ppk"] != null) $this->setDeskripsiParamsValue($params, "ppk", $referensi);
			if($params["art"] != null) $this->setDeskripsiParamsValue($params, "art", $referensi);
			if($params["tb_dm"] != null) $this->setDeskripsiParamsValue($params, "tb_dm", $referensi);
			if($params["terapi_dm"] != null) $this->setDeskripsiParamsValue($params, "terapi_dm", $referensi);
			if($params["pindah_ro"] != null) $this->setDeskripsiParamsValue($params, "pindah_ro", $referensi);
			if($params["toraks_tdk_dilakukan"] != null) $this->setDeskripsiParamsValue($params, "toraks_tdk_dilakukan", $referensi);
			if($params["asal_poli"] != "") {
				if($referensi) {
					if($referensi["asal_poli"]) $params["asal_poli"] = $referensi["asal_poli"]["ID"]." - ".$referensi["asal_poli"]["DESKRIPSI"];
				}
			}
						
			unset($params["REFERENSI"]);
	        $uri = "senddata";
	       
	        /* kirim data sitb */
	        $response = $this->sendRequestData([
	            "action" => $uri,
	            "method" => "POST",
	            "data" => $params
	        ]);
	        
	        $result = $this->getResultRequest($response);			
	        if(isset($result["status"])) {
				$status = [
					"berhasil" => 1,
					"update berhasil" => 1,
					"sukses" => 1
				];
	            if(isset($status[$result["status"]])) {
	                $row["kirim"] = 0;
	                if(isset($result["id_tb_03"])) {
	                    $row["id_tb_03"] = $result["id_tb_03"];
	                }
	                $this->service->simpanData($row);
	            }
	        }
	    }
		if(isset($id)) return $result;
	    
	    return [
	        "data" => $froms
	    ];
	}

	private function setDeskripsiParamsValue(&$params, $field, $referensi) {
		if($referensi) {
			if(isset($referensi[$field])) $params[$field] = $referensi[$field]["DESKRIPSI"];
		}
	}	
}
