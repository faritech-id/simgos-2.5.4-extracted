<?php
namespace General\V1\Rpc\PhotoPegawai;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService {
	public function __construct() {
		$this->config["entityName"] = "General\\V1\\Rpc\\PhotoPegawai\\Entity";
		$this->config["entityId"] = "NIP";
		$this->config["autoIncrement"] = false;
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("photo_pegawai", "gambar"));
    }    
}