<?php
namespace LISService\winacom\dbservice\registration;

use DBService\DatabaseService;
use DBService\Service as DBService;

class Service extends DBService
{	
    public function __construct() {
		$this->config["entityName"] = "LISService\\winacom\\dbservice\\registration\\Entity";
		$this->config["entityId"] = "order_number";
		$this->config["autoIncrement"] = false;
        $this->table = DatabaseService::get('Winacom')->get('registration');
		$this->entity = new Entity();
    }
}