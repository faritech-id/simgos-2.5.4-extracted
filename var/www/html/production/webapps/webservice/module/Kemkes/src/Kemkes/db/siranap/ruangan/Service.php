<?php
namespace Kemkes\db\siranap\ruangan;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService {
	protected $limit = 3000;
	
	public function __construct() {
		$this->config["entityName"] = "Kemkes\\db\\siranap\\ruangan\\Entity";
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("kemkes_ruangan", "master"));
    }
}