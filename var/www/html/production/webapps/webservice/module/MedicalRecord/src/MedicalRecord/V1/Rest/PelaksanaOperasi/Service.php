<?php
namespace MedicalRecord\V1\Rest\PelaksanaOperasi;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use General\V1\Rest\Referensi\ReferensiService;
use General\V1\Rest\Pegawai\PegawaiService;

class Service extends DBService {
	public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\PelaksanaOperasi\\PelaksanaOperasiEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("pelaksana_operasi", "medicalrecord"));
		$this->entity = new PelaksanaOperasiEntity();
	}

	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);

		if($this->includeReferences) {
			foreach($data as &$entity) {
				$results = $this->parseReferensi($entity, "jenis");
				if(count($results) > 0) $entity["REFERENSI"]["JENIS"] = $results;
				$results = $this->parseReferensi($entity, "pelaksana");
				if(count($results) > 0) $entity["REFERENSI"]["PELAKSANA"] = $results;
			}	
		}

		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'ID')) {
			$id = $params['ID'];
			$params['pelaksana_operasi.ID'] = $id;
			unset($params['ID']);
		}

		if(!System::isNull($params, 'JENIS')) {
			$jenis = $params['JENIS'];
			$params['pelaksana_operasi.JENIS'] = $jenis;
			unset($params['JENIS']);
		}

		if(!System::isNull($params, 'STATUS')) {
			$status = $params['STATUS'];
			$params['pelaksana_operasi.STATUS'] = $status;
			unset($params['STATUS']);
		}

		$select->join(
			["jenis" => new TableIdentifier('referensi', 'master')],
			new \Laminas\Db\Sql\Predicate\Expression("jenis.ID = pelaksana_operasi.JENIS AND jenis.JENIS = 214"),
			['jenis_ID' => 'ID', 'jenis_DESKRIPSI' => 'DESKRIPSI']
		);

		$select->join(
			["pelaksana" => new TableIdentifier('pegawai', 'master')],
			new \Laminas\Db\Sql\Predicate\Expression("pelaksana.ID = pelaksana_operasi.PELAKSANA"),
			[
				'pelaksana_ID' => 'ID',
				'pelaksana_GELAR_DEPAN' => 'GELAR_DEPAN',
				'pelaksana_NAMA' => 'NAMA', 'pelaksana_GELAR_BELAKANG' => 'GELAR_BELAKANG'
			],
			$select::JOIN_LEFT
		);
	}
}