<?php
namespace Kemkes\RSOnline\db\referensi\kecamatan;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService {
	public function __construct() {
		$this->limit = 5000;
        $this->config["entityName"] = "Kemkes\\RSOnline\\db\\referensi\\kecamatan\\Entity";
		$this->config["entityId"] = "kode";	
		$this->config["autoIncrement"] = false;
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("kecamatan", "kemkes-rsonline"));
    }    
}