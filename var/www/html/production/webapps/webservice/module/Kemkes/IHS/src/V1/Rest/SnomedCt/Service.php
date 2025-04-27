<?php
namespace Kemkes\IHS\V1\Rest\SnomedCt;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;

class Service extends DBService
{    
    public function __construct($includeReferences = true, $references = []) {
        $this->config["entityName"] = "Kemkes\\IHS\\V1\\Rest\\SnomedCt\\SnomedCtEntity";
        $this->config["autoIncrement"] = false;
        $this->config["entityId"] = "id";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("snomed_ct", "kemkes-ihs"));
        $this->entity = new SnomedCtEntity();
    }

    protected function queryCallback(Select &$select, &$params, $columns, $orders) {
        if(!System::isNull($params, 'term')) {
            $select->where->like('term', '%'.$params['term'].'%');
            unset($params['term']);
		}
    }
}