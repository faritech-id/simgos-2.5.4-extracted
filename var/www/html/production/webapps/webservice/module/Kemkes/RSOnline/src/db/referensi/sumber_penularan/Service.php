<?php
namespace Kemkes\RSOnline\db\referensi\sumber_penularan;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService {
	public function __construct() {
        $this->config["entityName"] = "Kemkes\\RSOnline\\db\\referensi\\sumber_penularan\\Entity";
		$this->config["entityId"] = "id_source";
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("sumber_penularan", "kemkes-rsonline"));
    }    
}