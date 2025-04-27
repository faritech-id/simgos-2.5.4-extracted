<?php
namespace PenjaminRS\V1\Rest\Drivers;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService {
    public function __construct($includeReferences = true, $references = []){
		$this->config["entityName"] = "\\PenjaminRS\\V1\\Rest\\Drivers\\DriversEntity";
        $this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("drivers","penjamin_rs"));
    }
}