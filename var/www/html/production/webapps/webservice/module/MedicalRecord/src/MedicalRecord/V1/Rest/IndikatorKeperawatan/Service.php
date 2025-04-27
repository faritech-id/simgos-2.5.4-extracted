<?php
namespace MedicalRecord\V1\Rest\IndikatorKeperawatan;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use MedicalRecord\V1\Rest\MappingIndikatorDiagnosa\Service as mappingIndikatorService;

class Service extends DBService {
	private $mapping;
	
	public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\IndikatorKeperawatan\\IndikatorKeperawatanEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("indikator_keperawatan", "medicalrecord"));
		$this->entity = new IndikatorKeperawatanEntity();

		$this->includeReferences = $includeReferences;
		if($includeReferences) $this->mapping = new mappingIndikatorService();
	}

	public function load($params = [], $columns = ['*'], $orders = []) {
		$getmap = false;
		if(isset($params['MAPPING'])){
			$getmap = true;
			unset($params['MAPPING']);
		}

		$data = parent::load($params, $columns, $orders);

		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($getmap){
					$mapping = $this->mapping->load(['INDIKATOR' => $entity['ID'], 'JENIS' => $entity['JENIS']]);
                	if(count($mapping) > 0) $entity['REFERENSI']['MAPPING_INDIKATOR'] = $mapping;
				}                
			}
		}
		
		return $data;
	}

    protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'QUERY')) {
			$select->where("indikator_keperawatan.DESKRIPSI LIKE '%".$params['QUERY']."%'");
			unset($params['QUERY']);
		}
	}
}