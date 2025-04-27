<?php
namespace LISService\lis\hasillog;

use DBService\DatabaseService;
use DBService\Service as DBService;
use Laminas\Db\Sql\TableIdentifier;

class Service extends DBService
{	
    public function __construct() {
        $this->config["entityName"] = "LISService\\lis\\hasillog\\Entity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier('hasil_log', 'lis'));
        $this->entity = new Entity();
    }
}