<?php
namespace Pendaftaran\V1\Rest\Pemohon;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as dbService;
class Service extends dbService{

    public function __construct($includeReferences = true, $references = []){
        $this->config["entityName"] = "\\Pendaftaran\\V1\\Rest\\Pemohon\\PemohonEntity";
        $this->config["entityId"] = "ID";
        $this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("pemohon","pendaftaran"));
        $this->entity = new PemohonEntity();		
    }
}