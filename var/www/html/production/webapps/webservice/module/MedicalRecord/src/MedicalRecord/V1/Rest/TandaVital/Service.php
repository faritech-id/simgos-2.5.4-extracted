<?php
namespace MedicalRecord\V1\Rest\TandaVital;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use General\V1\Rest\Referensi\ReferensiService;

class Service extends DBService {
	private $referensi;

	public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\TandaVital\\TandaVitalEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("tanda_vital", "medicalrecord"));
		$this->entity = new TandaVitalEntity();
		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		$this->referensi = new ReferensiService();
	}
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);

		if($this->includeReferences) {
			foreach($data as &$entity) {
				$referensi = $this->referensi->load(['JENIS' => 179, 'ID' => $entity['TINGKAT_KESADARAN']]);
				if(count($referensi) > 0) $entity['REFERENSI']['TINGKAT_KESADARAN'] = $referensi[0];
			}
		}
		
		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'STATUS')) {
			$status = $params['STATUS'];
			$params['tanda_vital.STATUS'] = $status;
			unset($params['STATUS']);
		}
		
		if(!System::isNull($params, 'HISTORY')) {
			unset($params['HISTORY']);
		
			$select->join(['k'=>new TableIdentifier('kunjungan', 'pendaftaran')], 'k.NOMOR = tanda_vital.KUNJUNGAN', []);
			$select->join(['p'=>new TableIdentifier('pendaftaran', 'pendaftaran')], 'p.NOMOR = k.NOPEN', []);
			$select->where("k.FINAL_HASIL = 1");

			if(!System::isNull($params, 'NORM')) {
				$norm = $params['NORM'];
				$params['p.NORM'] = $norm;
				unset($params['NORM']);
			}
		}
	}
}