<?php
namespace Kemkes\RSOnline\db\referensi\jenis_pasien;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService {
	public function __construct() {
        $this->config["entityName"] = "Kemkes\\RSOnline\\db\\referensi\\jenis_pasien\\Entity";
		$this->config["entityId"] = "id_jenis_pasien";
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("jenis_pasien", "kemkes-rsonline"));
    }    
}