<?php
namespace General\V1\Rest\KartuIdentitasKeluarga;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService
{
    public function __construct() {
		$this->config["entityName"] = "General\\V1\\Rest\\KartuIdentitasKeluarga\\KartuIdentitasKeluargaEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("kartu_identitas_keluarga", "master"));
		$this->entity = new KartuIdentitasKeluargaEntity();	
    }
}