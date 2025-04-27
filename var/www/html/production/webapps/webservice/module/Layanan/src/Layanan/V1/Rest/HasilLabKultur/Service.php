<?php
namespace Layanan\V1\Rest\HasilLabKultur;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;

use General\V1\Rest\Dokter\DokterService;

class Service extends DBService {
    private $dokter;
    
    protected $references = [
        'Dokter' => true
	];
    
	public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "Layanan\\V1\\Rest\\HasilLabKultur\\HasilLabKulturEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("hasil_lab_kultur", "layanan"));
		$this->entity = new HasilLabKulturEntity();
		
		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {
		    if($this->references['Dokter']) $this->dokter = new DokterService();
		}
	}
	
	public function load($params = [], $columns = ['*'], $orders = []) {
	    $data = parent::load($params, $columns, $orders);
	    
	    if($this->includeReferences) {
	        foreach($data as &$entity) {
	            if($this->references['Dokter']) {
	                $dokter = $this->dokter->load(['ID' => $entity['DOKTER']]);
	                if(count($dokter) > 0) $entity['REFERENSI']['DOKTER'] = $dokter[0];
	            }
	        }
	    }
	    
	    return $data;
	}
	
}