<?php
namespace BPJService\db\lpk;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService {
	public function __construct() {
		$this->config["entityName"] = "BPJService\\db\\lpk\\Entity";
		$this->config["entityId"] = "noSep";
		$this->config["autoIncrement"] = false;
        $this->table = DatabaseService::get('BPJS')->get(new TableIdentifier("lpk", "bpjs"));
    }
}