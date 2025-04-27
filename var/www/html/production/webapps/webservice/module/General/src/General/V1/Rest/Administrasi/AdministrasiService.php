<?php
namespace General\V1\Rest\Administrasi;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use Zend\json\Json;
use DBService\System;
use DBService\Service;

class AdministrasiService extends Service
{
    public function __construct() {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("administrasi", "master"));
		$this->entity = new AdministrasiEntity();
    }
}