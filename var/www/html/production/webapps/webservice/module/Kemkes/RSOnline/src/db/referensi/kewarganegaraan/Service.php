<?php
namespace Kemkes\RSOnline\db\referensi\kewarganegaraan;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService {
	public function __construct() {
		$this->limit = 5000;
        $this->config["entityName"] = "Kemkes\\RSOnline\\db\\referensi\\kewarganegaraan\\Entity";
		$this->config["entityId"] = "id_nation";
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("kewarganegaraan", "kemkes-rsonline"));
    }    
}