<?php
namespace Kemkes\RSOnline\db\referensi\status_isolasi;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService {
	public function __construct() {
        $this->config["entityName"] = "Kemkes\\RSOnline\\db\\referensi\\status_isolasi\\Entity";
		$this->config["entityId"] = "id_isolasi";
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("status_isolasi", "kemkes-rsonline"));
    }    
}