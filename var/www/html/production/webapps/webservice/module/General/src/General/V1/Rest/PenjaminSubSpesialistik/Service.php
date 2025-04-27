<?php
namespace General\V1\Rest\PenjaminSubSpesialistik;

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
		$this->config["entityName"] = "General\\V1\\Rest\\PenjaminSubSpesialistik\\PenjaminSubSpesialistikEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("penjamin_sub_spesialistik", "master"));
		$this->entity = new PenjaminSubSpesialistikEntity();
		
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
	                $penjamin = $this->referensi->load(['JENIS' => 10, 'ID' => $entity['PENJAMIN']]);
	                if(count($penjamin) > 0) $entity['REFERENSI']['PENJAMIN'] = $penjamin[0];
	                
	                $smf = $this->referensi->load(['JENIS' => 26,'ID' => $entity['SUB_SPESIALIS_RS']]);
	                if(count($smf) > 0) $entity['REFERENSI']['SUB_SPESIALIS_RS'] = $smf[0];
	            }
	        }
	    }
	    
	    return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'STATUS')) {
			$status = $params['STATUS'];
			$params['penjamin_sub_spesialistik.STATUS'] = $status;
			unset($params['STATUS']);
		}
	}	
}