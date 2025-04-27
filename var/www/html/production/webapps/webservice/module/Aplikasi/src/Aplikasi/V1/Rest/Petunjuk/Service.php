<?php
namespace Aplikasi\V1\Rest\Petunjuk;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\Service as DBService;

class Service extends DBService {
	public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "Aplikasi\\V1\\Rest\\Petunjuk\\PetunjukEntity";		
		$this->config["autoIncrement"] = false;
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("petunjuk", "aplikasi"));
	}
	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(isset($params["ID"])) {
			$select->where->like("ID", $params["ID"]."%");
			unset($params["ID"]);
		}
	}
	
}