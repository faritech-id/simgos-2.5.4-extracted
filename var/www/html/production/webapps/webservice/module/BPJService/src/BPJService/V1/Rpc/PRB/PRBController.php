<?php
namespace BPJService\V1\Rpc\PRB;

use DBService\RPCResource;
use Laminas\View\Model\JsonModel;

class PRBController extends RPCResource
{    
    private $service;
	
	public function __construct($service) 
	{
		$this->service = $service->getPRBService();
		$this->config = $this->service->getConfig();
	}

    public function create($data) {
        $data = $this->service->prb("POST", (array) $data);
		
		return new JsonModel([
            'data' => $data
        ]);
    }

    public function update($id, $data)
    {
		$data->noSep = $id;
        $data = $this->service->prb("PUT", (array) $data);
		
		return new JsonModel([
            'data' => $data
        ]);
    }
	
	public function deleteAction()
    {
		$data = $this->getPostData($this->getRequest());
        $data = $this->service->prb("DELETE", (array) $data);
		
		return new JsonModel([
            'data' => $data
        ]);
    }

    public function cariSRBBerdasarkanNomorAction()
    {
        $params = (array) $this->getRequest()->getQuery();
        $data = $this->service->cariSRBBerdasarkanNomor($params);
        
        return new JsonModel([
            'data' => $data
        ]);
    }

    public function cariSRBBerdasarkanTanggalAction()
    {
        $params = (array) $this->getRequest()->getQuery();
        $data = $this->service->cariSRBBerdasarkanTanggal($params);
        
        return new JsonModel([
            'data' => $data
        ]);
    }
}
