<?php
namespace Kemkes\IHS\V1\Rest\CodeReference;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;

class Service extends DBService
{    
    public function __construct($includeReferences = true, $references = []) {
        $this->config["entityName"] = "Kemkes\\IHS\\V1\\Rest\\CodeReference\\CodeReferenceEntity";
        $this->config["autoIncrement"] = false;
        $this->config["entityId"] = "id";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("code_reference", "kemkes-ihs"));
        $this->entity = new CodeReferenceEntity();
    }

    protected function queryCallback(Select &$select, &$params, $columns, $orders) {
        if(!System::isNull($params, 'entity')) {
            $select->where->like('entity', '%'.$params['entity'].'%');
			unset($params['entity']);
		}
    }
}