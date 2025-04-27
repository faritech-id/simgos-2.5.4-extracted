<?php
namespace Kemkes\RSOnline\db\referensi\jenis_kelamin;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService {
	public function __construct() {
        $this->config["entityName"] = "Kemkes\\RSOnline\\db\\referensi\\jenis_kelamin\\Entity";
		$this->config["entityId"] = "id_gender";
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("jenis_kelamin", "kemkes-rsonline"));
    }    
}