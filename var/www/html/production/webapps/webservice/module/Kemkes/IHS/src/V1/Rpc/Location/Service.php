<?php
namespace Kemkes\IHS\V1\Rpc\Location;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService
{    
    public function __construct($includeReferences = true, $references = []) 
    {
        $this->config["entityName"] = "Kemkes\\IHS\\V1\\Rpc\\Location\\Entity";
        $this->config["autoIncrement"] = false;
        $this->config["entityId"] = "refId";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("location", "kemkes-ihs"));
        $this->entity = new Entity();
    }
     
    public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
        $desstatus = [
            "1" => "active",
            "2" => "suspended",
            "3" => "inactive"
        ];
        foreach($data as &$entity) {
            $entity["status"] = $desstatus[$entity["status"]] ;
        }
		
		return $data;
	}
}