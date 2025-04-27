<?php
namespace BPJService\db\referensi\dpjp;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService {

	public function __construct() {
		$this->config["entityName"] = "BPJService\\db\\referensi\\dpjp\\Entity";
		$this->config["entityId"] = "kode";
		$this->config["autoIncrement"] = false;
        $this->table = DatabaseService::get('BPJS')->get(new TableIdentifier("dpjp", "bpjs"));
    }
}