<?php
namespace PenjaminRS\V1\Rest\CaraKeluar;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService{
    public function __construct($includeReferences = true, $references = []){
		$this->config["entityName"] = "\\PenjaminRS\\V1\\Rest\\CaraKeluar\\CaraKeluarEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("cara_keluar","penjamin_rs"));
    }
}