<?php
namespace Kemkes\RSOnline\db\referensi\tempat_tidur;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService {
	public function __construct() {
		$this->limit = 5000;
        $this->config["entityName"] = "Kemkes\\RSOnline\\db\\referensi\\tempat_tidur\\Entity";
		$this->config["entityId"] = "kode_tt";
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("tempat_tidur", "kemkes-rsonline"));
    }    
}