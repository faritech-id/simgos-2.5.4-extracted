<?php
namespace LISService\winacom\dbservice\demographics;

use DBService\DatabaseService;
use DBService\Service as DBService;

class Service extends DBService
{	
    public function __construct() {
		$this->config["entityName"] = "LISService\\winacom\\dbservice\\demographics\\Entity";
		$this->config["entityId"] = "patient_id";
		$this->config["autoIncrement"] = false;
        $this->table = DatabaseService::get('Winacom')->get('demographics');
		$this->entity = new Entity();
    }
}