<?php
namespace Plugins\V2\Rpc\Bpjs;

use Laminas\Json\Json;

class Rujukan
{    
    private $controller;
	
	public function __construct($controller) 
	{
		$this->controller = $controller;
	}

	public function cariRujukanDgnNoRujukan() 
	{				
		$id = $this->controller->params()->fromRoute('id', 0);
		$data = $this->controller->validateRequest($this->controller->sendRequest('rujukan/cariNoRujukan/'.$id));
		if(isset($data['status'])) return $data;
		return [
			'success' => true,
			'data' => $data
		];
    }
	
	public function cariRujukanDgnNoKartuBPJS() 
	{
		$id = $this->controller->params()->fromRoute('id', 0);
		$data = $this->controller->validateRequest($this->controller->sendRequest('rujukan/cariNoKartuBPJS/'.$id));
		if(isset($data['status'])) return $data;
		return [
			'success' => true,
			'data' => $data
		];
    }
    
    /* Rujukan>>>Berdasarkan Nomor Kartu (Multi Record)
	 * cari data rujukan berdasarkan Nomor Kartu BPJS (Multi Record)
	 * @parameter 
	 *   $params string | array("noKartu" => value, "faskes" => value | 1 = Faskes 1; 2 = Faskes 2/RS )
	 *   $uri string
	 */
    public function list() {
        $params = (array) $this->controller->getRequest()->getQuery();
        $query = count($params) > 0 ? "?".http_build_query($params) : "";
        $data = $this->controller->validateRequest($this->controller->sendRequest("rujukan/listRujukan".$query));
        if(isset($data['status'])) return $data;
        $list = isset($data["rujukan"]) ? $data["rujukan"] : null;
        $total = isset($data["count"]) ? $data["count"] : (isset($list) ? count($list) : 0);
        $data = $total > 0 ? $list : null;
        return [
            'success' => true
            , 'total' => $total
            , 'data' => $data
		];
    }
	
	public function insert() 
	{
		$data = Json::encode($this->controller->getPostData($this->controller->getRequest()));
		$data = $this->controller->validateRequest($this->controller->sendRequest('rujukan', "POST", $data));
		if(isset($data['status'])) return $data;
		return [
			'success' => true,
			'data' => $data
		];
    }
	
	public function update() 
	{
		$data = Json::encode($this->controller->getPostData($this->controller->getRequest()));
		$data = $this->controller->validateRequest($this->controller->sendRequest('rujukan/'.$data->noRujukan, "PUT", $data));
		if(isset($data['status'])) return $data;
		return [
			'success' => true,
			'data' => $data
		];
    }
	
	public function delete() 
	{
		$data = Json::encode($this->controller->getPostData($this->controller->getRequest()));
		$data = $this->controller->validateRequest($this->controller->sendRequest('rujukan/delete', "POST", $data));
		if(isset($data['status'])) return $data;
		return [
			'success' => true,
			'data' => $data
		];
    }
	
	public function simpan() 
	{
		$data = Json::encode($this->controller->getPostData($this->controller->getRequest()));
		$data = $this->controller->validateRequest($this->controller->sendRequest('rujukan/simpan', "POST", $data));
		if(isset($data['status'])) return $data;
		return [
			'success' => true,
			'data' => $data
		];
    }

	public function listSpesialistik() {
        $params = (array) $this->controller->getRequest()->getQuery();		
        $query = count($params) > 0 ? "?".http_build_query($params) : "";
        $data = $this->controller->validateRequest($this->controller->sendRequest("rujukan/listSpesialistikRujukan".$query));
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

	public function listSarana() {
        $params = (array) $this->controller->getRequest()->getQuery();		
        $query = count($params) > 0 ? "?".http_build_query($params) : "";
        $data = $this->controller->validateRequest($this->controller->sendRequest("rujukan/listSarana".$query));
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

	public function insertRujukanKhusus() 
	{
		$data = Json::encode($this->controller->getPostData($this->controller->getRequest()));
		$data = $this->controller->validateRequest($this->controller->sendRequest('rujukan/insertRujukanKhusus', "POST", $data));
		if(isset($data['status'])) return $data;
		return [
			'success' => true,
			'data' => $data
		];
    }

	public function deleteRujukanKhusus() 
	{
		$data = Json::encode($this->controller->getPostData($this->controller->getRequest()));
		$data = $this->controller->validateRequest($this->controller->sendRequest('rujukan/deleteRujukanKhusus', "POST", $data));
		if(isset($data['status'])) return $data;
		return [
			'success' => true,
			'data' => $data
		];
    }

	public function listRujukanKhusus() {
        $params = (array) $this->controller->getRequest()->getQuery();	
        $query = count($params) > 0 ? "?".http_build_query($params) : "";
        $data = $this->controller->validateRequest($this->controller->sendRequest("rujukan/listRujukanKhusus".$query));
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