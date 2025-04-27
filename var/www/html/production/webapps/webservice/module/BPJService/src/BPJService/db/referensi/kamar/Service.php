<?php
namespace BPJService\db\referensi\kamar;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService {

	public function __construct() {
		$this->config["entityName"] = "BPJService\\db\\referensi\\kamar\\Entity";
		$this->config["entityId"] = "kodekelas";
		$this->config["autoIncrement"] = false;
        $this->table = DatabaseService::get('BPJS')->get(new TableIdentifier("kamar", "bpjs"));
    }
}