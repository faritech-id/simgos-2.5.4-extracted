<?php
namespace BPJService\db\rujukan\masuk;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService {
	public function __construct() {
		$this->config["entityName"] = "BPJService\\db\\rujukan\\masuk\\Entity";
		$this->config["entityId"] = "noKunjungan";
		$this->config["autoIncrement"] = false;
        $this->table = DatabaseService::get('BPJS')->get(new TableIdentifier("rujukan_masuk", "bpjs"));
    }
}