<?php
namespace MedicalRecord\V1\Rest\MappingIntervensiIndikator;

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
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\MappingIntervensiIndikator\\MappingIntervensiIndikatorEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("mapping_intervensi_indikator", "medicalrecord"));
		$this->entity = new MappingIntervensiIndikatorEntity();

        $this->diagnosa = new diagnosaService();
		$this->indikator = new indikatorService(false);
	}

    public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);

		if($this->includeReferences) {
			foreach($data as &$entity) {
				if(isset($entity['DIAGNOSA'])) {
					$diagnosa = $this->diagnosa->load(['ID' => $entity['DIAGNOSA']]);
					if(count($diagnosa) > 0) $entity['REFERENSI']['DIAGNOSA'] = $diagnosa[0];
				}
				$indikator = $this->indikator->load(['ID' => $entity['INDIKATOR'], 'JENIS' => $entity['JENIS']]);
                if(count($indikator) > 0) $entity['REFERENSI']['INDIKATOR'] = $indikator[0];
			}
		}		
		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'QUERY')) {
			$select->join(
				['ik' => new TableIdentifier('indikator_keperawatan', 'medicalrecord')],
                new \Laminas\Db\Sql\Predicate\Expression("ik.ID = mapping_intervensi_indikator.INDIKATOR AND ik.JENIS=". $params["JENIS"]),
				[]
			);
			$select->where("(ik.DESKRIPSI LIKE '%".$params['QUERY']."%')");
			unset($params['QUERY']);
		}

		if(!System::isNull($params, 'JENIS')) {
			$params["mapping_intervensi_indikator.JENIS"] = $params["JENIS"];
			unset($params["JENIS"]);
		}

		if(!System::isNull($params, 'STATUS')) {
			$params["mapping_intervensi_indikator.STATUS"] = $params["STATUS"];
			unset($params["STATUS"]);
		}
	}
}