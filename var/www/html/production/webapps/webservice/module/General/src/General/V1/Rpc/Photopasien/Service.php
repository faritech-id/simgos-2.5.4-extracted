<?php
namespace General\V1\Rpc\Photopasien;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService {
	public function __construct() {
		$this->config["entityName"] = "General\\V1\\Rpc\\Photopasien\\Entity";
		$this->config["entityId"] = "NORM";
		$this->config["autoIncrement"] = false;
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("photo_pasien", "gambar"));
    }    
}