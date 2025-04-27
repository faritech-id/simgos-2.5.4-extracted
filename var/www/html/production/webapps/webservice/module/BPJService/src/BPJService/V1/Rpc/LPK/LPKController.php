<?php
namespace BPJService\V1\Rpc\LPK;

use DBService\RPCResource;
use Laminas\View\Model\JsonModel;

class LPKController extends RPCResource
{
    private $service;
	
	public function __construct($service) 
	{
		$this->service = $service->getLPKService();
		$this->config = $this->service->getConfig();
	}

    public function create($data) {
        $data = $this->service->lpk("POST", (array) $data);
		
		return new JsonModel([
            'data' => $data
        ]);
    }

    public function update($id, $data)
    {
		$data->noSep = $id;
        $data = $this->service->lpk("PUT", (array) $data);
		
		return new JsonModel([
            'data' => $data
        ]);
    }
	
	public function deleteAction()
    {
		$data = $this->getPostData($this->getRequest());
        $data = $this->service->lpk("DELETE", (array) $data);
		
		return new JsonModel([
            'data' => $data
        ]);
    }

    /**
     * Return list of resources
     *
     * @return mixed
     */
    public function getList()
    {
        $params = (array) $this->getRequest()->getQuery();
        $data = $this->service->list($params);
        
        return new JsonModel([
            'data' => $data
        ]);
    }
}
