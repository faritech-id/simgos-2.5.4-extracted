<?php
namespace TTE\V1\Db\sign;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService {
	public function __construct() {
	    $this->config["entityName"] = "\\TTE\\V1\\Db\\sign\\Entity";
	    $this->config["autoIncrement"] = false;
		$this->config["generateUUID"] = true;
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("sign", "tte"));
    }
}