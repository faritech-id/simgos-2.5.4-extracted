<?php
namespace Layanan\V1\Rest\HasilLabMikroskopikDetail;

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
		$this->config["entityName"] = "Layanan\\V1\\Rest\\HasilLabMikroskopikDetail\\HasilLabMikroskopikDetailEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("hasil_lab_mikroskopik_detail", "layanan"));
		$this->entity = new HasilLabMikroskopikDetailEntity();
		
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
	                $pemeriksaan = $this->referensi->load(['ID' => $entity['PEMERIKSAAN'], 'JENIS' => 134]);
	                if(count($pemeriksaan) > 0) $entity['REFERENSI']['PEMERIKSAAN'] = $pemeriksaan[0];
	            }
	        }
	    }
	    
	    return $data;
	}
	
	
}