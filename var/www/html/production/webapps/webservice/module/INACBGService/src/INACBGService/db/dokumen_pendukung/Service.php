<?php
namespace INACBGService\db\dokumen_pendukung;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;

class Service extends DBService {

	public function __construct($includeReferences = true, $references = array()) {
        $this->config["entityName"] = "INACBGService\\db\\dokumen_pendukung\Entity";
        $this->config["entityId"] = "id";

		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("dokumen_pendukung", "inacbg"));
		$this->entity = new Entity();
	}

	protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
		if($isCreated) {
			if(!isset($data["tanggal"])) $entity->set('tanggal', new \Laminas\Db\Sql\Expression('NOW()'));
		}
	}

	public function load($params = [], $columns = ['*'], $orders = []) {		
		$data = parent::load($params, $columns, $orders);
		
		foreach($data as &$entity) {
			$results = $this->parseReferensi($entity, "pengguna");
			if(count($results) > 0) $entity["REFERENSI"]["PENGGUNA"] = $results;
		}
		
		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'id')) {
			$params['dokumen_pendukung.id'] = $params['id'];
			unset($params['id']);
		}

		if(!System::isNull($params, 'status')) {
			$params['dokumen_pendukung.status'] = $params['status'];
			unset($params['status']);
		}

		$select->join(
			['u' => new TableIdentifier('pengguna', 'aplikasi')],
			'u.ID = OLEH',
			[],
			Select::JOIN_LEFT
		);
		
		$select->join(
			['p' => new TableIdentifier('pegawai', 'master')],
			'p.NIP = u.NIP',
			['pengguna_GELAR_DEPAN' => 'GELAR_DEPAN', 'pengguna_NAMA' => 'NAMA', 'pengguna_GELAR_BELAKANG' => 'GELAR_BELAKANG'],
			Select::JOIN_LEFT
		);
	}

	public function hapus($params = []) {
		$this->table->delete($params);
		return true;
	}
}