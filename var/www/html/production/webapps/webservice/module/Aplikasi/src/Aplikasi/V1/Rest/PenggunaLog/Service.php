<?php
namespace Aplikasi\V1\Rest\PenggunaLog;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;

class Service extends DBService {
	public function __construct() {
		$this->config["entityName"] = "Aplikasi\\V1\\Rest\\PenggunaLog\\PenggunaLogEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("pengguna_log", "aplikasi"));
		$this->entity = new PenggunaLogEntity();
	}
}