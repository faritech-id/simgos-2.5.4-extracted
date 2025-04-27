<?php
namespace Pegawai\V1\Rest\KontakPegawai;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use General\V1\Rest\Referensi\ReferensiService;

class KontakPegawaiService extends DBService {
	
	public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "\\Pegawai\\V1\\Rest\\KontakPegawai\\KontakPegawaiEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("kontak_pegawai", "pegawai"));
		$this->entity = new KontakPegawaiEntity();
		$this->setReferences($references);
		$this->includeReferences = $includeReferences;
		$this->referensi = new ReferensiService();
	}
	
	public function load($params = [], $columns = ['*'], $edukasipasienkeluargas = []) {
		$data = parent::load($params, $columns, $edukasipasienkeluargas);
		
		foreach($data as &$entity) {
			$jeniskontak = $this->referensi->load(['ID' => $entity['JENIS'], 'JENIS' => 8]);
			if(count($jeniskontak) > 0) $entity['REFERENSI']['JENIS'] = $jeniskontak[0];
		}
		
		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'NIP')) {
			$params['kontak_pegawai.NIP'] = $params['NIP'];
			unset($params['NIP']);
		}
	}
}