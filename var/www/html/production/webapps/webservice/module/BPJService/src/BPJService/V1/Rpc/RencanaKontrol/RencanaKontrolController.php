<?php
namespace BPJService\V1\Rpc\RencanaKontrol;

use DBService\RPCResource;
use Laminas\View\Model\JsonModel;

class RencanaKontrolController extends RPCResource
{
    private $service;
	
	public function __construct($service) 
	{
        $this->service = $service->getRencanaKontrolService();
		$this->config = $this->service->getConfig();
	}

    public function create($data) {
        $data = $this->service->rencanaKontrol("POST", (array) $data);
		
		return new JsonModel([
            'data' => $data
        ]);
    }

    public function update($id, $data)
    {
		//$data->noSuratKontrol = $id;
        $data = $this->service->rencanaKontrol("PUT", (array) $data);
		
		return new JsonModel([
            'data' => $data
        ]);
    }
	
	public function deleteAction()
    {
		$data = $this->getPostData($this->getRequest());
        $data = $this->service->rencanaKontrol("DELETE", (array) $data);
		
		return new JsonModel([
            'data' => $data
        ]);
    }

    public function sepAction()
    {        		
		$id = $this->params()->fromRoute('id', 0);
		$data = $this->service->cariSEP($id);
		
		return new JsonModel([
            'data' => $data
        ]);
    }

    /**
     * Return single resource
     *
     * @param  mixed $id
     * @return mixed
     */
    public function get($id)
    {
        $data = $this->service->cariNomorSurat($id);
		
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

    /**
     * Return list of resources
     *
     * @return mixed
     */
    public function dataPoliAction()
    {
        $params = (array) $this->getRequest()->getQuery();
        $data = $this->service->dataPoli($params);
        
        return new JsonModel([
            'data' => $data
        ]);
    }

    /**
     * Return list of resources
     *
     * @return mixed
     */
    public function dataDokterAction()
    {
        $params = (array) $this->getRequest()->getQuery();
        $data = $this->service->dataDokter($params);
        
        return new JsonModel([
            'data' => $data
        ]);
    }
}
