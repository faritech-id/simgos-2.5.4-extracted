<?php
namespace Plugins\V2\Rpc\Bpjs;

use Laminas\Json\Json;

class Monitoring
{    
    private $controller;
	
	public function __construct($controller) 
	{
		$this->controller = $controller;
	}

    public function kunjungan()
    {     
		$params = (array) $this->controller->getRequest()->getQuery();
		$tanggal = isset($params["tanggal"]) ? $params["tanggal"] : "";
		$jenis = isset($params["jenis"]) ? $params["jenis"] : "";
		$data = $this->controller->validateRequest($this->controller->sendRequest('monitoring/kunjungan?tanggal='.$tanggal.'&jenis='.$jenis));
		if(isset($data['status'])) return $data;
		$list = isset($data["list"]) ? $data["list"] : null;
		$total = isset($data["count"]) ? $data["count"] : (isset($list) ? count($list) : 0);
		$data = $total > 0 ? $list : null;
		return [
			'success' => true
			, 'total' => $total
			, 'data' => $data
		];
    }
	
	public function klaim()
    {     
        $params = (array) $this->controller->getRequest()->getQuery();
        $query = count($params) > 0 ? "?".http_build_query($params) : "";
        $data = $this->controller->validateRequest($this->controller->sendRequest('monitoring/klaim'.$query));
        if(isset($data['status'])) return $data;
        $list = isset($data["list"]) ? $data["list"] : null;
        $total = isset($data["count"]) ? $data["count"] : (isset($list) ? count($list) : 0);
        $data = $total > 0 ? $list : null;
        return [
            'success' => true
            , 'total' => $total
            , 'data' => $data
		];
    }
    
    /* Monitoring Data Histori Pelayanan Peserta
     * @parameter
     *   $params array(
     *		"noKartu" => value | No.Kartu Peserta
     *		"tglMulai" => value | Tgl Mulai Pencarian (yyyy-mm-dd)
     *		"tglAkhir" => value | Tgl Akhir Pencarian (yyyy-mm-dd)
     *)
     */
    public function historiPelayanan() {
        $params = (array) $this->controller->getRequest()->getQuery();
        $query = count($params) > 0 ? "?".http_build_query($params) : "";
        $data = $this->controller->validateRequest($this->controller->sendRequest("monitoring/historiPelayanan".$query));
        if(isset($data['status'])) return $data;
        $list = isset($data["list"]) ? $data["list"] : null;
        $total = isset($data["count"]) ? $data["count"] : (isset($list) ? count($list) : 0);
        $data = $total > 0 ? $list : null;
        return [
            'success' => true
            , 'total' => $total
            , 'data' => $data
		];
    }
    
    /* Monitoring Data Klaim Jaminan Jasa Raharja
	 * @parameter
	 *   $params array(
	 *		"tglMulai" => value | Tgl Mulai Pencarian (yyyy-mm-dd)
	 *		"tglAkhir" => value | Tgl Akhir Pencarian (yyyy-mm-dd)
	 *)
     */
    public function klaimJaminanJasaRaharja() {
        $params = (array) $this->controller->getRequest()->getQuery();
        $query = count($params) > 0 ? "?".http_build_query($params) : "";
        $data = $this->controller->validateRequest($this->controller->sendRequest("monitoring/klaimJaminanJasaRaharja".$query));
        if(isset($data['status'])) return $data;
        $list = isset($data["list"]) ? $data["list"] : null;
        $total = isset($data["count"]) ? $data["count"] : (isset($list) ? count($list) : 0);
        $data = $total > 0 ? $list : null;
        return [
            'success' => true
            , 'total' => $total
            , 'data' => $data
		];
	}
}