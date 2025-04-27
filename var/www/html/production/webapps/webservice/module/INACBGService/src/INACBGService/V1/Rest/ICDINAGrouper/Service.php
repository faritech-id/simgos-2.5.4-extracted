<?php
namespace INACBGService\V1\Rest\ICDINAGrouper;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;

class Service extends DBService {
	public function __construct($includeReferences = true, $references = []) {
        $this->config["entityName"] = "INACBGService\\V1\\Rest\ICDINAGrouper\\ICDINAGrouperEntity";
        $this->config["entityId"] = "code";
        $this->config["autoIncrement"] = false;

		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("icd_ina_grouper", "inacbg"));
		$this->entity = new ICDINAGrouperEntity();
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'query')) {
			$query = $params['query'];
			unset($params['query']);
			$params[] = new \Laminas\Db\Sql\Predicate\Expression("(code = ? OR description LIKE ?)", [$params["query"]."%", "%".$params["query"]."%"]);
		}
	}
}