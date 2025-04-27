<?php
namespace BPJService\db\rencana_kontrol;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService {
	public function __construct() {
		$this->config["entityName"] = "BPJService\\db\\rencana_kontrol\\Entity";
		$this->config["entityId"] = "noSurat";
		$this->config["autoIncrement"] = false;
        $this->table = DatabaseService::get('BPJS')->get(new TableIdentifier("rencana_kontrol", "bpjs"));
    }
}