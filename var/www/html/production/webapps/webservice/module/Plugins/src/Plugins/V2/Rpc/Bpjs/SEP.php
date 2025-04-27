<?php
namespace Plugins\V2\Rpc\Bpjs;

use Laminas\Json\Json;

class SEP
{    
    private $controller;
	
	public function __construct($controller) 
	{
		$this->controller = $controller;
	}

	public function create($data)
    {        
		$data = $this->controller->validateRequest($this->controller->sendRequest('kunjungan', 'POST', Json::encode($data)));
		if(isset($data['status'])) return $data;
		return [
			'success' => true,
			'data' => $data
		];
    }
	
	public function update()
    {       
		$data = Json::encode($this->controller->getPostData($this->controller->getRequest()));
		$data = $this->controller->validateRequest($this->controller->sendRequest('kunjungan/updateSEP', 'POST', $data));
		if(isset($data['status'])) return $data;
		return [
			'success' => true,
			'data' => $data
		];
    }
	
	/**
	 * @depricated
	 */
	public function mappingDataTransaksi()
    {       
		$data = Json::encode($this->controller->getPostData($this->controller->getRequest()));
		$data = $this->controller->validateRequest($this->controller->sendRequest('kunjungan/mappingDataTransaksi', 'POST', $data));
		if(isset($data['status'])) return $data;
		return [
			'success' => true,
			'data' => $data
		];
    }
	
	public function updateTanggalPulang()
    {       
		$data = Json::encode($this->controller->getPostData($this->controller->getRequest()));
		$data = $this->controller->validateRequest($this->controller->sendRequest('kunjungan/updateTanggalPulang', 'POST', $data));
		if(isset($data['status'])) return $data;
		return [
			'success' => true,
			'data' => $data
		];
    }
	
	public function cek()
    {    
		$id = $this->controller->params()->fromRoute('id', 0);
		$data = Json::encode(["noSEP"=>$id]);
		$data = $this->controller->validateRequest($this->controller->sendRequest('kunjungan/cekSEP', 'POST', $data));
		if(isset($data['status'])) return $data;
		return [
			'success' => true,
			'data' => $data
		];
    }
	
	public function batalkan()
    {       
		$data = Json::encode($this->controller->getPostData($this->controller->getRequest()));
		$data = $this->controller->validateRequest($this->controller->sendRequest('kunjungan/batalkanSEP', 'POST', $data));
		if(isset($data['status'])) return $data;
		return [
			'success' => true,
			'data' => $data
		];
    }
	
	public function pengajuan()
    {       
		$data = Json::encode($this->controller->getPostData($this->controller->getRequest()));
		$data = $this->controller->validateRequest($this->controller->sendRequest('kunjungan/pengajuanSEP', 'POST', $data));
		if(isset($data['status'])) return $data;
		return [
			'success' => true,
			'data' => $data
		];
    }
	
	public function aprovalPengajuan()
    {       
		$data = Json::encode($this->controller->getPostData($this->controller->getRequest()));
		$data = $this->controller->validateRequest($this->controller->sendRequest('kunjungan/aprovalPengajuanSEP', 'POST', $data));
		if(isset($data['status'])) return $data;
		return [
			'success' => true,
			'data' => $data
		];
    }
	
	public function daftarPengajuan()
    {     
		$params = (array) $this->controller->getRequest()->getQuery();		
		$noKartu = isset($params["noKartu"]) ? $params["noKartu"] : "";
		$start = isset($params["start"]) ? $params["start"] : 0;
		$limit = isset($params["limit"]) ? $params["limit"] : 25;
		$status = isset($params["status"]) ? $params["status"] : 1;
		
		$query = "?start=".$start."&limit=".$limit.($noKartu == "" ? "" : "&noKartu=".$noKartu).($status == "" ? "" : "&status=".$status);
		$data = $this->controller->validateRequest($this->controller->sendRequest('kunjungan/daftarPengajuan'.$query));
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
	
	public function batalPengajuan()
    {       
		$data = Json::encode($this->controller->getPostData($this->controller->getRequest()));
		$data = $this->controller->validateRequest($this->controller->sendRequest('kunjungan/batalPengajuanSEP', 'POST', $data));
		if(isset($data['status'])) return $data;
		return [
			'success' => true,
			'data' => $data
		];
    }
	
	/** @depricated */
	public function kunjunganPeserta()
    {       
		$data = Json::encode($this->controller->getPostData($this->controller->getRequest()));
		$data = $this->controller->validateRequest($this->controller->sendRequest('kunjungan/kunjunganPeserta', 'POST', $data));
		if(isset($data['status'])) return $data;
		return [
			'success' => true,
			'data' => $data
		];
    }
	
	/** @depricated */
	public function monitoringVerifikasiKlaim()
    {       
		$data = Json::encode($this->controller->getPostData($this->controller->getRequest()));
		$data = $this->controller->validateRequest($this->controller->sendRequest('kunjungan/monitoringVerifikasiKlaim', 'POST', $data));
		if(isset($data['status'])) return $data;
		return [
			'success' => true,
			'data' => $data
		];
    }
	
	/** @depricated */
	public function riwayatPelayananPeserta()
    {       
		$data = Json::encode($this->controller->getPostData($this->controller->getRequest()));
		$data = $this->controller->validateRequest($this->controller->sendRequest('kunjungan/riwayatPelayananPeserta', 'POST', $data));
		if(isset($data['status'])) return $data;
		return [
			'success' => true,
			'data' => $data
		];
    }
	
	public function inacbg()
    {       
		$data = Json::encode($this->controller->getPostData($this->controller->getRequest()));
		$data = $this->controller->validateRequest($this->controller->sendRequest('kunjungan/inacbg', 'POST', $data));
		if(isset($data['status'])) return $data;
		return [
			'success' => true,
			'data' => $data
		];
    }

	public function suplesiJasaRaharja() {
        $params = (array) $this->controller->getRequest()->getQuery();		
        $query = count($params) > 0 ? "?".http_build_query($params) : "";
        $data = $this->controller->validateRequest($this->controller->sendRequest("kunjungan/suplesiJasaRaharja".$query));
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

	public function dataIndukKecelakaan()
	{						
		$params = (array) $this->controller->getRequest()->getQuery();
		$nomor = !empty($params["noKartu"]) ? $params["noKartu"] : "0";
		$data = $this->controller->validateRequest($this->controller->sendRequest('kunjungan/dataIndukKecelakaan/'.$nomor));
		if(isset($data['status'])) return $data;
		return [
			'success' => true,
			'data' => $data
		];
    }

	public function listDataUpdateTanggalPulang() {
        $params = (array) $this->controller->getRequest()->getQuery();		
        $query = count($params) > 0 ? "?".http_build_query($params) : "";
        $data = $this->controller->validateRequest($this->controller->sendRequest("kunjungan/listDataUpdateTanggalPulang".$query));
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

	public function sepInternal()
	{						
		$params = (array) $this->controller->getRequest()->getQuery();
		$sep = !empty($params["noSep"]) ? $params["noSep"] : "0";
		$data = $this->controller->validateRequest($this->controller->sendRequest('kunjungan/sepInternal/'.$sep));
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

	public function hapusSepInternal()
    {       
		$data = Json::encode($this->controller->getPostData($this->controller->getRequest()));
		$data = $this->controller->validateRequest($this->controller->sendRequest('kunjungan/hapusSepInternal', 'POST', $data));
		if(isset($data['status'])) return $data;
		return [
			'success' => true,
			'data' => $data
		];
    }

	public function getFingerPrint() {
        $params = (array) $this->controller->getRequest()->getQuery();		
        $query = count($params) > 0 ? "?".http_build_query($params) : "";
        $data = $this->controller->validateRequest($this->controller->sendRequest("kunjungan/getFingerPrint".$query));
        if(isset($data['status'])) return $data;
        return [
            'success' => true
            , 'data' => $data
		];
    }

	public function getListFingerPrint() {
        $params = (array) $this->controller->getRequest()->getQuery();		
        $query = count($params) > 0 ? "?".http_build_query($params) : "";
        $data = $this->controller->validateRequest($this->controller->sendRequest("kunjungan/getListFingerPrint".$query));
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

	function getFingerAppRequestAccess() {
		$params = (array) $this->controller->getRequest()->getQuery();
        $query = count($params) > 0 ? "?".http_build_query($params) : "";
        $data = $this->controller->validateRequest($this->controller->sendRequest("kunjungan/getFingerAppRequestAccess".$query));
        if(isset($data['status'])) return $data;
        return [
            'success' => true
            , 'data' => $data
		];
	}
}