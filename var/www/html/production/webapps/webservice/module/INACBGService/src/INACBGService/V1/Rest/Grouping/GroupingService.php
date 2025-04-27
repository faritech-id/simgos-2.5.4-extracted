<?php
namespace INACBGService\V1\Rest\Grouping;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;

class GroupingService extends Service
{	
    public function __construct() {
        $this->config["entityName"] = "INACBGService\\V1\\Rest\\Grouping\\GroupingEntity";
        $this->config["entityId"] = 'NOPEN';
        $this->config["autoIncrement"] = false;
        $this->table = DatabaseService::get('INACBG')->get(new TableIdentifier("grouping", "inacbg"));
        $this->entity = new GroupingEntity();
    }
}
