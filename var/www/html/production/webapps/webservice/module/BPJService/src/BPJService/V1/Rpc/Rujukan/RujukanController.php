<?php
namespace BPJService\V1\Rpc\Rujukan;

use DBService\RPCResource;

use Laminas\View\Model\JsonModel;
use Laminas\Json\Json;

class RujukanController extends RPCResource
{
	private $service;
	
	public function __construct($service) 
	{
		$this->service = $service->getRujukanService();
		$this->config = $this->service->getConfig();
	}
		
	public function cariNoRujukanAction()
    {        		
		$id = $this->params()->fromRoute('id', 0);
		$data = $this->service->cariRujukanDgnNoRujukan($id);
		
		return new JsonModel([
            'data' => $data
        ]);
    }
	
	public function cariNoKartuBPJSAction()
    {        
		$id = $this->params()->fromRoute('id', 0);
		$data = $this->service->cariRujukanDgnNoKartuBPJS($id);
		
		return new JsonModel([
            'data' => $data
        ]);
    }
    
    public function listRujukanAction()
    {
        $params = (array) $this->getRequest()->getQuery();
        $data = $this->service->listRujukanDgnNoKartuBPJS($params);
        
        return new JsonModel([
            'data' => $data
        ]);
    }
	
	public function create($data)
    {
		$data = $this->service->insertRujukan((array) $data);
		
		return new JsonModel([
            'data' => $data
        ]);
    }
	
	public function update($id, $data)
    {
		$data->noRujukan = $id;
        $data = $this->service->updateRujukan((array) $data);
		
		return new JsonModel([
            'data' => $data
        ]);
    }
	
	public function deleteAction()
    {
		$data = $this->getPostData($this->getRequest());
        $data = $this->service->deleteRujukan((array) $data);
		
		return new JsonModel([
            'data' => $data
        ]);
    }
	
	public function simpanAction()
    {
		$data = (array) $this->getPostData($this->getRequest());
		$rujukan = $this->service->getRujukan();
		
		if(isset($data["noSep"])) {
			$result = $rujukan->load([
				"noSep" => $data["noSep"],
				"status" => 1
			]);
		}
		if(isset($data["noRujukan"])) {
			$result = $rujukan->load([
				"noRujukan" => $data["noRujukan"],
				"status" => 1
			]);
		}
		
		if(count($result) == 0) {
			$params = $data;
			$data = $this->service->insertRujukan($params);
		} else if(count($result) > 0) {
			if(isset($data["status"])) {
				$params = $data;
				unset($params["status"]);
				$data = $this->service->deleteRujukan($params);
			} else {
				$params = $data;
				$data = $this->service->updateRujukan($params);
			}
		}
        
		return new JsonModel([
            'data' => $data
        ]);
    }

	public function listSpesialistikRujukanAction()
    {
        $params = (array) $this->getRequest()->getQuery();
        $data = $this->service->listSpesialistikRujukan($params);
        
        return new JsonModel([
            'data' => $data
        ]);
    }

	public function listSaranaAction()
    {
        $params = (array) $this->getRequest()->getQuery();
        $data = $this->service->listSarana($params);
        
        return new JsonModel([
            'data' => $data
        ]);
    }

	public function insertRujukanKhususAction()
    {
		$data = (array) $this->getPostData($this->getRequest());
		$data = $this->service->insertRujukanKhusus($data);
		
		return new JsonModel([
            'data' => $data
        ]);
    }

	public function deleteRujukanKhususAction()
    {
		$data = (array) $this->getPostData($this->getRequest());
		$data = $this->service->deleteRujukanKhusus($data);
		
		return new JsonModel([
            'data' => $data
        ]);
    }

	public function listRujukanKhususAction()
    {
        $params = (array) $this->getRequest()->getQuery();
        $data = $this->service->listRujukanKhusus($params);
        
        return new JsonModel([
            'data' => $data
        ]);
    }
}
