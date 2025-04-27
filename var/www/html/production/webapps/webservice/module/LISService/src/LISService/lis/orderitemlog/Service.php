<?php
namespace LISService\lis\orderitemlog;

use DBService\DatabaseService;
use DBService\Service as DBService;
use Laminas\Db\Sql\TableIdentifier;

class Service extends DBService
{	
    public function __construct() {
		$this->config["entityName"] = "LISService\\lis\\orderitemlog\\Entity";
		$this->config["entityId"] = "HIS_ID";
		$this->config["autoIncrement"] = false;
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier('order_item_log', 'lis'));
		$this->entity = new Entity();
		$this->limit = 10;
    }	
}