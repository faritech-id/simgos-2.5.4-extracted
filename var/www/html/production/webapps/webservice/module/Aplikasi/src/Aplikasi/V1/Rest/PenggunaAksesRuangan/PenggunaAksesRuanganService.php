<?php
namespace Aplikasi\V1\Rest\PenggunaAksesRuangan;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;

class PenggunaAksesRuanganService extends Service
{
    public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "Aplikasi\\V1\\Rest\\PenggunaAksesRuangan\\PenggunaAksesRuanganEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("pengguna_akses_ruangan", "aplikasi"));
		$this->limit = 5000;
		$this->entity = new PenggunaAksesRuanganEntity();
	}
	
	protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
		$entity->set('TANGGAL', new \Laminas\Db\Sql\Expression('NOW()'));
	}
}
