<?php
namespace Pegawai\V1\Rest\KartuIdentitas;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService
{
    public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "\\Pegawai\\V1\\Rest\\KartuIdentitas\\KartuIdentitasEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("kartu_identitas", "pegawai"));
		$this->entity = new KartuIdentitasEntity();
	}    
}