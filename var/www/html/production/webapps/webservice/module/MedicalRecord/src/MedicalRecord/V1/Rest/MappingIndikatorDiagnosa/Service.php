<?php
namespace MedicalRecord\V1\Rest\MappingIndikatorDiagnosa;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use MedicalRecord\V1\Rest\DiagnosaKeperawatan\Service as diagnosaService;
use MedicalRecord\V1\Rest\IndikatorKeperawatan\Service as indikatorService;

class Service extends DBService {
    private $diagnosa;
	private $indikator; 
	
	public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\MappingIndikatorDiagnosa\\MappingIndikatorDiagnosaEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("mapping_diagnosa_indikator", "medicalrecord"));
		$this->entity = new MappingIndikatorDiagnosaEntity();

        $this->diagnosa = new diagnosaService();
		$this->indikator = new indikatorService(false);
	}

    public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);

		if($this->includeReferences) {
			foreach($data as &$entity) {
                $diagnosa = $this->diagnosa->load(['ID' => $entity['DIAGNOSA']]);
                if(count($diagnosa) > 0) $entity['REFERENSI']['DIAGNOSA'] = $diagnosa[0];

				$indikator = $this->indikator->load(['ID' => $entity['INDIKATOR'], 'JENIS' => $entity['JENIS']]);
                if(count($indikator) > 0) $entity['REFERENSI']['INDIKATOR'] = $indikator[0];
			}
		}
		
		return $data;
	}
}