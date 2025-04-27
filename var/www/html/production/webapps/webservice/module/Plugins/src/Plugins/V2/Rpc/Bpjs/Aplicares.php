<?php
namespace Plugins\V2\Rpc\Bpjs;

use Laminas\Json\Json;

class Aplicares
{    
    private $controller;
	
	public function __construct($controller) 
	{
		$this->controller = $controller;
	}

	public function referensiKamar() {
		$data = $this->controller->validateRequest($this->controller->sendRequest("aplicares/referensiKamar"));		
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

	public function ketersediaanKamarRS() {
		$params = (array) $this->controller->getRequest()->getQuery();
        $query = count($params) > 0 ? "?".http_build_query($params) : "";
        $data = $this->controller->validateRequest($this->controller->sendRequest("aplicares/ketersediaanKamarRS".$query));
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

	public function tempatTidur() {
		$params = (array) $this->controller->getRequest()->getQuery();
        $query = count($params) > 0 ? "?".http_build_query($params) : "";
        $data = $this->controller->validateRequest($this->controller->sendRequest("aplicares/tempatTidur".$query));
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

	public function hapusTempatTidur()
    {       
		$data = Json::encode($this->controller->getPostData($this->controller->getRequest()));
		$data = $this->controller->validateRequest($this->controller->sendRequest('aplicares/hapusTempatTidur', 'POST', $data));
		if(isset($data['status'])) return $data;
		return [
			'success' => true,
			'data' => $data
		];
	}
	
	public function mapKelas()
    {       
		$request = $this->controller->getRequest();
        $method = $request->getMethod();        
		$data = Json::encode($this->controller->getPostData($request));
		$data = $this->controller->validateRequest($this->controller->sendRequest('aplicares/mapKelas', ($method != "GET" ? 'POST' : "GET"), $data));
		if(isset($data['status'])) return $data;

		$total = 0;
		if($method == "GET") {
			$list = isset($data["list"]) ? $data["list"] : null;
			$total = isset($data["count"]) ? $data["count"] : (isset($list) ? count($list) : 0);
			$data = $total > 0 ? $list : null;			
		}

		return [
			'success' => true
			, 'total' => $total
			, 'data' => $data
		];
    }
}