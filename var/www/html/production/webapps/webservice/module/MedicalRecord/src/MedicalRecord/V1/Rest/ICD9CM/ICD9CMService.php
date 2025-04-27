<?php
namespace MedicalRecord\V1\Rest\ICD9CM;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;
use Laminas\Db\Sql\Select;
use Laminas\Db\Sql\Expression;
use DBService\System;

use General\V1\Rest\Diagnosa\DiagnosaService;

class ICD9CMService extends Service
{
	private $diagnosa;
	
    public function __construct() {
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\ICD9CM\\ICD9CMEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("prosedur", "medicalrecord"));
		$this->entity = new ICD9CMEntity();
		
		$this->diagnosa = new DiagnosaService();
    }

	protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
		$entity->set('TANGGAL', new \Laminas\Db\Sql\Expression('NOW()'));
	}

	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		
		foreach($data as &$entity) {
			$diagnosa = $this->diagnosa->load(['CODE' => $entity['KODE'], 'ICD9' => 1]);
			if(count($diagnosa) > 0) $entity['REFERENSI']['DIAGNOSA'] = $diagnosa[0];
		}
		
		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'STATUS')) {
			$status = $params['STATUS'];
			$params['prosedur.STATUS'] = $status;
			unset($params['STATUS']);
		}
		
		if(!System::isNull($params, 'HISTORY')) {
			unset($params['HISTORY']);

			$select->join(['p'=>new TableIdentifier('pendaftaran', 'pendaftaran')], 'p.NOMOR = prosedur.NOPEN', []);
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