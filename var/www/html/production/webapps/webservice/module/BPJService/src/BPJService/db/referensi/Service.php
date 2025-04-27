<?php
namespace BPJService\db\referensi;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;
use DBService\System;
use Laminas\Db\Sql\Select;

class Service extends DBService {
	public function __construct() {
        $this->config["entityName"] = "BPJService\\db\\referensi\\Entity";
		$this->config["entityId"] = "id";
		$this->entity = new $this->config["entityName"]();
        $this->table = DatabaseService::get('BPJS')->get(new TableIdentifier("referensi", "bpjs"));
    }
}