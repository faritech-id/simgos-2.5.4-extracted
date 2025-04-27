<?php
namespace Plugins\V2\Rpc\Bpjs;

class Peserta
{    
    private $controller;
	
	public function __construct($controller) 
	{
		$this->controller = $controller;
	}

	/* cari peserta */
	public function get($id) 
	{
		$params = (array) $this->controller->getRequest()->getQuery();
		$tgl = isset($params["tglSEP"]) ? $params["tglSEP"] : "";
		
		$data = $this->controller->validateRequest($this->controller->sendRequest('peserta/'.$id."?tglSEP=".$tgl));
		if(isset($data['status'])) return $data;
		return [
			'success' => true,
			'data' => $data['peserta']
		];
	}

	public function nik() 
	{
		$id = $this->controller->params()->fromRoute('id', 0);
		$params = (array) $this->controller->getRequest()->getQuery();
		$tgl = isset($params["tglSEP"]) ? $params["tglSEP"] : "";
		$data = $this->controller->sendRequest('peserta/nik/'.$id."?tglSEP=".$tgl);
		$data = $this->controller->validateRequest($data);
		if(isset($data['status'])) return $data;
		return [
			'success' => true,
			'data' => $data['peserta']
		];
    }
}