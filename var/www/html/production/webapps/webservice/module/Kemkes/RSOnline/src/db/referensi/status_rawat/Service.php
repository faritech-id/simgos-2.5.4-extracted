<?php
namespace Kemkes\RSOnline\db\referensi\status_rawat;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService {
	public function __construct() {
        $this->config["entityName"] = "Kemkes\\RSOnline\\db\\referensi\\status_rawat\\Entity";
		$this->config["entityId"] = "id_status_rawat";
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("status_rawat", "kemkes-rsonline"));
    }    
}