<?php
namespace MedicalRecord\V1\Rest\ICD10;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;
use Laminas\Db\Sql\Select;
use Laminas\Db\Sql\Expression;
use DBService\System;
use Aplikasi\V1\Rest\Pengguna\PenggunaService;
use General\V1\Rest\Diagnosa\DiagnosaService;

class ICD10Service extends Service
{
	private $pengguna;
	protected $references = [
		'Pengguna' => true
	];

    public function __construct() {
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\ICD10\\ICD10Entity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("diagnosa", "medicalrecord"));
		$this->entity = new ICD10Entity();
		$this->diagnosa = new DiagnosaService();
		$this->pengguna = new PenggunaService();
    }

	protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
		$entity->set('TANGGAL', new \Laminas\Db\Sql\Expression('NOW()'));
	}

	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		
		foreach($data as &$entity) {
			$diagnosa = $this->diagnosa->load(['CODE' => $entity['KODE']]);
			if(count($diagnosa) > 0) $entity['REFERENSI']['DIAGNOSA'] = $diagnosa[0];
			$pengguna = $this->pengguna->load(['ID' => $entity['OLEH']], ['ID', 'NAMA', 'NIP', 'NIK']);
			if(count($pengguna) > 0) $entity['REFERENSI']['OLEH'] = $pengguna[0];
		}
		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'STATUS')) {
			$status = $params['STATUS'];
			$params['diagnosa.STATUS'] = $status;
			unset($params['STATUS']);
		}
		
		if(!System::isNull($params, 'HISTORY')) {
			unset($params['HISTORY']);
					
			$select->join(['p'=>new TableIdentifier('pendaftaran', 'pendaftaran')], 'p.NOMOR = diagnosa.NOPEN', []);
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