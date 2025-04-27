<?php
namespace General\V1\Rest\AntibiotikBakteri;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use General\V1\Rest\Referensi\ReferensiService;

class Service extends DBService {
    private $referensi;
   
    protected $references = [
		'Referensi' => true
    ];
   
   	public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "General\\V1\\Rest\\AntibiotikBakteri\\AntibiotikBakteriEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("antibiotik_bakteri", "master"));
		$this->entity = new AntibiotikBakteriEntity();
		
		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {
		    if($this->references['Referensi']) $this->referensi = new ReferensiService();
		}
	}
	
	public function load($params = [], $columns = ['*'], $orders = []) {
	    $data = parent::load($params, $columns, $orders);
	    
	    if($this->includeReferences) {
	        foreach($data as &$entity) {
	            if($this->references['Referensi']) {
	                $antibiotik = $this->referensi->load(['ID' => $entity['ANTIBIOTIK'], 'JENIS' => 128]);
	                if(count($antibiotik) > 0) $entity['REFERENSI']['ANTIBIOTIK'] = $antibiotik[0];
	                
	                $bakteri = $this->referensi->load(['ID' => $entity['BAKTERI'], 'JENIS' => 129]);
	                if(count($bakteri) > 0) $entity['REFERENSI']['BAKTERI'] = $bakteri[0];
	            }
	        }
	    }
	    
	    return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'STATUS')) {
			$status = $params['STATUS'];
			$params['antibiotk_bakteri.STATUS'] = $status;
			unset($params['STATUS']);
		}
	}
}