<?php
namespace BPJService\db\prb;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService {
	public function __construct() {
		$this->config["entityName"] = "BPJService\\db\\prb\\Entity";
		$this->config["entityId"] = "noSRB";
		$this->config["autoIncrement"] = false;
        $this->table = DatabaseService::get('BPJS')->get(new TableIdentifier("prb", "bpjs"));
    }
}