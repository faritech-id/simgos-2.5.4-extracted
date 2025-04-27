<?php
namespace Pembayaran\V1\Rest\Diskon;

use DBService\DatabaseService;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;
use Laminas\Db\Sql\TableIdentifier;

class DiskonService extends Service
{
    public function __construct() {
		$this->config["entityName"] = "Pembayaran\\V1\\Rest\\Diskon\\DiskonEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("diskon", "pembayaran"));
		$this->entity = new DiskonEntity();
    }
}
