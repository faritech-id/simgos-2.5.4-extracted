<?php
namespace Plugins\V2\Rpc\Bpjs;

use Laminas\Json\Json;

class LPK
{    
    private $controller;
	
	public function __construct($controller) 
	{
		$this->controller = $controller;
	}

    public function lpk()
	{				
		$request = $this->controller->getRequest();
		$id = $this->controller->params()->fromRoute('id');
		$params = (array) $request->getQuery();
        $query = count($params) > 0 ? "?".http_build_query($params) : "";
		$data = Json::encode($this->controller->getPostData($request));
		$method = $request->getMethod();
		$uris = [
			"GET" => "lpk".(!is_null($id) ? "/".$id : $query),
			"POST" => "lpk",
			"PUT"  => "lpk/".$id,
			"DELETE" => "lpk/delete"
		];
		$method = $method == "DELETE" ? "POST" : $method;
		
		$data = $this->controller->validateRequest($this->controller->sendRequest($uris[$method], $method, $data));
		if(isset($data['status'])) return $data;
		if($method == "GET" && is_null($id)) {
			$list = isset($data["list"]) ? $data["list"] : null;
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
}
