<?php
namespace Kemkes\RSOnline\db\referensi\status_keluar;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService {
	public function __construct() {
        $this->config["entityName"] = "Kemkes\\RSOnline\\db\\referensi\\status_keluar\\Entity";
		$this->config["entityId"] = "id_status";
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("status_keluar", "kemkes-rsonline"));
    }    
}