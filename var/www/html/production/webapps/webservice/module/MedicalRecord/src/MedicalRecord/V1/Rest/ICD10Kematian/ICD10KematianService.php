<?php
namespace MedicalRecord\V1\Rest\ICD10Kematian;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;
use Laminas\Db\Sql\Select;
use Laminas\Db\Sql\Expression;
use DBService\System;

use General\V1\Rest\Diagnosa\DiagnosaService;

class ICD10KematianService extends Service
{
    public function __construct() {
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\ICD10Kematian\\ICD10KematianEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("diagnosa_meninggal", "medicalrecord"));
		$this->entity = new ICD10KematianEntity();
		
		$this->diagnosa = new DiagnosaService();
    }

	protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
		$entity->set('TANGGAL', new \Laminas\Db\Sql\Expression('NOW()'));
	}
		
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		
		foreach($data as &$entity) {
			$diagnosa = $this->diagnosa->load(['CODE' => $entity['KODE']]);
			if(count($diagnosa) > 0) $entity['REFERENSI']['DIAGNOSA'] = $diagnosa[0];
		}
		
		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'STATUS')) {
			$status = $params['STATUS'];
			$params['diagnosa_meninggal.STATUS'] = $status;
			unset($params['STATUS']);
		}
		
		if(!System::isNull($params, 'HISTORY')) {
			unset($params['HISTORY']);

			$select->join(['p'=>new TableIdentifier('pendaftaran', 'pendaftaran')], 'p.NOMOR = diagnosa_meninggal.NOPEN', []);
			$select->join(['k'=>new TableIdentifier('kunjungan', 'pendaftaran')], 'k.NOPEN = p.NOMOR', []);
			$select->where("k.FINAL_HASIL = 1");

			if(!System::isNull($params, 'NORM')) {
				$norm = $params['NORM'];
				$params['p.NORM'] = $norm;
				unset($params['NORM']);
			}
		}
	}
}