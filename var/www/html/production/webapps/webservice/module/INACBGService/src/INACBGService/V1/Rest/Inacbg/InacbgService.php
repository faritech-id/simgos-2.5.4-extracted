<?php
namespace INACBGService\V1\Rest\Inacbg;

use DBService\DatabaseService;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;

class InacbgService extends Service
{
    public function __construct() {
		$this->config["entityName"] = "INACBGService\\V1\\Rest\\Inacbg\\InacbgEntity";		
        $this->table = DatabaseService::get("INACBG")->get('inacbg'); 
		$this->entity = new InacbgEntity();
		$this->limit = 10000;
    }
}
