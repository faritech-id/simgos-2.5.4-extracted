<?php
namespace LISService\V1\Rest\Parameter;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;

class Service extends DBService {
	public function __construct($includeReferences = true, $references = array()) {
		$this->config["entityName"] = "LISService\\V1\\Rest\\Parameter\\ParameterEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("parameter_lis", "lis"));
		$this->entity = new ParameterEntity();
	}
}