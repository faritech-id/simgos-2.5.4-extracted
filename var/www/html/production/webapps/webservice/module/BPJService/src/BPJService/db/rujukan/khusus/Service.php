<?php
namespace BPJService\db\rujukan\khusus;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService {
	public function __construct() {
		$this->config["entityName"] = "BPJService\\db\\rujukan\\khusus\\Entity";
		$this->config["entityId"] = "noRujukan";
		$this->config["autoIncrement"] = false;
        $this->table = DatabaseService::get('BPJS')->get(new TableIdentifier("rujukan_khusus", "bpjs"));
    }
}