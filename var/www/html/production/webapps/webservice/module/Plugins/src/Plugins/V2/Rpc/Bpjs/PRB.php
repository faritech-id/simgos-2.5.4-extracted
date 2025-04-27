<?php
namespace Plugins\V2\Rpc\Bpjs;


class PRB
{    
    private $controller;
	
	public function __construct($controller) 
	{
		$this->controller = $controller;
	}

    public function prb()
	{				
		$request = $this->controller->getRequest();
		$id = $this->controller->params()->fromRoute('id');
		$data = Json::encode($this->controller->getPostData($request));
		$method = $request->getMethod();
		$uris = [
			"POST" => "prb",
			"PUT"  => "prb/".$id,
			"DELETE" => "prb/delete"
		];
		$method = $method == "DELETE" ? "POST" : $method;
		
		$data = $this->controller->validateRequest($this->controller->sendRequest($uris[$method], $method, $data));
		if(isset($data['status'])) return $data;
		return [
			'success' => true,
			'data' => $data
		];
    }

    public function cariSRBBerdasarkanNomor() {        
        $params = (array) $this->controller->getRequest()->getQuery();
        $query = count($params) > 0 ? "?".http_build_query($params) : "";
        $data = $this->controller->validateRequest($this->controller->sendRequest("prb/cariSRBBerdasarkanNomor".$query));
        if(isset($data['status'])) return $data;
		return [
			'success' => true,
			'data' => $data
		];
    }

	public function cariSRBBerdasarkanTanggal() {        
        $params = (array) $this->controller->getRequest()->getQuery();
        $query = count($params) > 0 ? "?".http_build_query($params) : "";
        $data = $this->controller->validateRequest($this->controller->sendRequest("prb/cariSRBBerdasarkanTanggal".$query));
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
