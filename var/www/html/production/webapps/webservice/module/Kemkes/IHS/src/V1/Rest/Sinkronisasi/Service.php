<?php
namespace Kemkes\IHS\V1\Rest\Sinkronisasi;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use DBService\generator\Generator;

class Service extends DBService
{
	private $sinkronisasi;
	
    public function __construct() {
        $this->config["entityName"] = "Kemkes\\IHS\\V1\\Rest\\Sinkronisasi\\SinkronisasiEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("sinkronisasi", "kemkes-ihs"));
		$this->entity = new SinkronisasiEntity();
    }
}
