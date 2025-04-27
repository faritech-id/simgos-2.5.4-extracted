<?php
namespace Kemkes\IHS\V1\Rpc\Organization;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;
use Laminas\Db\Sql\Select;
use DBService\System;

class Service extends DBService
{    
    public function __construct($includeReferences = true, $references = []) 
    {
        $this->config["entityName"] = "Kemkes\\IHS\\V1\\Rpc\\Organization\\Entity";
        $this->config["autoIncrement"] = false;
        $this->config["entityId"] = "refId";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("organization", "kemkes-ihs"));
        $this->entity = new Entity();
    }

    public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);

        foreach($data as &$entity) {
            $entity["active"] = $entity["active"] ? true : false;
        }
		
		return $data;
	}
}