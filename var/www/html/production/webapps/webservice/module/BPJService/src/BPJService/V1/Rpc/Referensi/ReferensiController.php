<?php
namespace BPJService\V1\Rpc\Referensi;

use DBService\RPCResource;

use Laminas\View\Model\JsonModel;
use Laminas\Json\Json;

use BPJService\db\referensi\Service as ReferensiStore;

class ReferensiController extends RPCResource
{
	private $service;
	private $store;
	
	public function __construct($service) 
	{
		$this->service = $service->getReferensiService();
		$this->config = $this->service->getConfig();
		$this->store = new ReferensiStore();
	}

	public function getList() {
		$params = (array) $this->getRequest()->getQuery();
		$entity = $this->store->getEntity();
		$entity->exchangeArray($params);
		$params = $entity->getArrayCopy();

		$result = $this->store->load($params);
		
		return new JsonModel([
            'data' => [
				'metadata' => [
					"code" => 200,
					"message" => "OK"
				],
				'response' => [
					"list" => $result,
					"count" => count($result)
				]
			]
		]);
	}
	
	public function poliAction() {
		$params = (array) $this->getRequest()->getQuery();
		if(count($params) > 0) {
			$data = $this->service->poli($params);
		} else {
			$data = $this->service->poli();
		}
		
		return new JsonModel([
            'data' => $data
		]);
	}
	
	public function diagnosaAction() {
		$params = (array) $this->getRequest()->getQuery();
		$data = $this->service->diagnosa($params);
		
		return new JsonModel([
            'data' => $data
		]);
	}
	
	public function procedureAction() {
		$params = (array) $this->getRequest()->getQuery();
		$data = $this->service->procedure($params);
		
		return new JsonModel([
            'data' => $data
        ]);
	}
	
	public function kelasRawatAction() {
		$data = $this->service->kelasRawat();
		
		return new JsonModel([
            'data' => $data
        ]);
	}
	
	public function dokterAction() {
		$params = (array) $this->getRequest()->getQuery();
		$data = $this->service->dokter($params);
		
		return new JsonModel([
            'data' => $data
        ]);
	}
	
	public function spesialistikAction() {
		$data = $this->service->spesialistik();
		
		return new JsonModel([
            'data' => $data
        ]);
	}
	
	public function ruangRawatAction() {
		$data = $this->service->ruangRawat();
		
		return new JsonModel([
            'data' => $data
        ]);
	}
	
	public function caraKeluarAction() {
		$data = $this->service->caraKeluar();
		
		return new JsonModel([
            'data' => $data
        ]);
	}
	
	public function pascaPulangAction() {
		$data = $this->service->pascaPulang();
		
		return new JsonModel([
            'data' => $data
        ]);
	}
	
	public function faskesAction() {
		$params = (array) $this->getRequest()->getQuery();
		
		$data = $this->service->faskes($params);
		
		return new JsonModel([
            'data' => $data
        ]);
	}
	
	public function dpjpAction() {
	    $params = (array) $this->getRequest()->getQuery();

		if(count($params) == 0) {
			$params = [
				"jenisPelayanan" => 1,
				"tglPelayanan" => date("Y-m-d"),
				"kodeSpesialis" => ""
			];
		}		
	    
	    $data = $this->service->dpjp($params);
	    
	    return new JsonModel([
	        'data' => $data
	    ]);
	}
	
	public function propinsiAction() {
	    $data = $this->service->propinsi();
	    
	    return new JsonModel([
	        'data' => $data
	    ]);
	}
	
	public function kabupatenAction() {
	    $params = (array) $this->getRequest()->getQuery();
	    $data = $this->service->kabupaten($params);
	    
	    return new JsonModel([
	        'data' => $data
	    ]);
	}
	
	public function kecamatanAction() {
	    $params = (array) $this->getRequest()->getQuery();
	    $data = $this->service->kecamatan($params);
	    
	    return new JsonModel([
	        'data' => $data
	    ]);
	}

	public function diagnosaPrbAction()
    {
        $data = $this->service->diagnosaPrb();
        
        return new JsonModel([
            'data' => $data
        ]);
    }

	public function obatGenerikPrbAction()
    {
		$params = (array) $this->getRequest()->getQuery();
        $data = $this->service->obatGenerikPrb($params);
        
        return new JsonModel([
            'data' => $data
        ]);
    }
}
