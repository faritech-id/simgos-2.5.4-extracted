<?php
namespace Plugins\V2\Rpc\Bpjs;

use Laminas\Json\Json;
use Plugins\db\bpjs\rencanakontrol\Service as DbRencanaKontrolService;

class RencanaKontrol
{    
    private $controller;
	
	public function __construct($controller) 
	{
		$this->controller = $controller;
		$this->dbrencanakontrol = new DbRencanaKontrolService();
	}

    public function rencanaKontrol() 
	{				
		$request = $this->controller->getRequest();
		$id = $this->controller->params()->fromRoute('id');
		$params = (array) $request->getQuery();
        $query = count($params) > 0 ? "?".http_build_query($params) : "";
		$data = Json::encode($this->controller->getPostData($request));
		$method = $request->getMethod();
		$uris = [
			"GET" => "rencana-kontrol".(!is_null($id) ? "/".$id : $query),
			"POST" => "rencana-kontrol",
			"PUT"  => "rencana-kontrol/".$id,
			"DELETE" => "rencana-kontrol/delete"
		];
		$uri = $uris[$method];
		$method = $method == "DELETE" ? "POST" : $method;

		$data = $this->controller->validateRequest($this->controller->sendRequest($uri, $method, $data));
		if(isset($data['status'])) return $data;
		if($method == "GET" && is_null($id)) {
			$list = isset($data["list"]) ? $data["list"] : null;
			foreach($list as $p) {
				$this->dbrencanakontrol->simpan($p);
			}
			$total = isset($data["count"]) ? $data["count"] : (isset($list) ? count($list) : 0);
			$data = $total > 0 ? $list : null;
			return [
				'success' => true,
				'total' => $total,
				'data' => $data
			];
		}
		return [
			'success' => true,
			'data' => $data
		];
    }

	public function sep() 
	{				
		$id = $this->controller->params()->fromRoute('id', 0);
		$data = $this->controller->validateRequest($this->controller->sendRequest("rencana-kontrol/sep/".$id));
		if(isset($data['status'])) return $data;
		return [
			'success' => true,
			'data' => $data
		];
    }
	    
    public function dataPoli() {
        $params = (array) $this->controller->getRequest()->getQuery();		
        $query = count($params) > 0 ? "?".http_build_query($params) : "";
        $data = $this->controller->validateRequest($this->controller->sendRequest("rencana-kontrol/dataPoli".$query));
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

	public function dataDokter() {
        $params = (array) $this->controller->getRequest()->getQuery();
        $query = count($params) > 0 ? "?".http_build_query($params) : "";
        $data = $this->controller->validateRequest($this->controller->sendRequest("rencana-kontrol/dataDokter".$query));
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
