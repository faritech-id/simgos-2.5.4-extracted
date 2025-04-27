<?php
namespace PenjaminRS\V1\Rest\Dpjp;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use General\V1\Rest\Dokter\DokterService;

class Service extends DBService{
    private $dokter;
    protected $references = [
		'Dokter' => true
	];

    public function __construct($includeReferences = true, $references = []){
        $this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("dpjp","penjamin_rs"));
        $this->entity = new DpjpEntity();
		$this->config["entityName"] = "\\PenjaminRS\\V1\\Rest\\Dpjp\\DpjpEntity";

		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		$this->limit = 1000;
		if($includeReferences) {			
			if($this->references['Dokter']) $this->dokter = new DokterService();
		}
    }

    public function load($params = [], $columns = ['*'], $orders = []){
        $data = parent::load($params, $columns, $orders);
		
        if($this->includeReferences) {
			foreach($data as &$entity) {				
				if($this->references['Dokter']) {
					$dokter = $this->dokter->load(['ID' => $entity['DPJP_RS']]);
					if(count($dokter) > 0) $entity['REFERENSI']['DOKTER'] = $dokter[0];
				}
			}
		}
		return $data;
    }
}