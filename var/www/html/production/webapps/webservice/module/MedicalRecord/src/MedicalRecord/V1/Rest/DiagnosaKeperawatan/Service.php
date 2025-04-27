<?php
namespace MedicalRecord\V1\Rest\DiagnosaKeperawatan;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;

class Service extends DBService {
	
	public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\DiagnosaKeperawatan\\DiagnosaKeperawatanEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("diagnosa_keperawatan", "medicalrecord"));
		$this->entity = new DiagnosaKeperawatanEntity();
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'QUERY')) {
			$params[] = new \Laminas\Db\Sql\Predicate\Expression("(KODE LIKE ? OR DESKRIPSI LIKE ?)", ["%".$params["QUERY"]."%", "%".$params["QUERY"]."%"]);
			unset($params['QUERY']);
		}
	}
}