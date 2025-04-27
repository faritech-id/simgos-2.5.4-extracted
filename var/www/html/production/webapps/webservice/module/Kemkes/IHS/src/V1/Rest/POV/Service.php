<?php
namespace Kemkes\IHS\V1\Rest\POV;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;

class Service extends DBService
{    
    public function __construct($includeReferences = true, $references = []) {
        $this->config["entityName"] = "Kemkes\\IHS\\V1\\Rest\\POV\\POVEntity";
        $this->config["autoIncrement"] = false;
        $this->config["entityId"] = "id";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("pov", "kemkes-ihs"));
        $this->entity = new POVEntity();
    }

    protected function queryCallback(Select &$select, &$params, $columns, $orders) {
        if(!System::isNull($params, 'display')) {
            $select->where->like('display', '%'.$params['display'].'%');
            unset($params['display']);
		}

         if(!System::isNull($params, 'query')) {
			$params[] = new \Laminas\Db\Sql\Predicate\Expression("(id = ? OR display LIKE ?)", [$params["query"], "%".$params["query"]."%"]);
			unset($params['query']);
		}
    }
}