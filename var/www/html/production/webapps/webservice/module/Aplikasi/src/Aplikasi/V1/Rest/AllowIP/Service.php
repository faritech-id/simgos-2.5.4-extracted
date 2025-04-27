<?php
namespace Aplikasi\V1\Rest\AllowIP;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService {
	public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "Aplikasi\\V1\\Rest\\AllowIP\\AllowIPEntity";
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("allow_ip_authentication", "aplikasi"));
		$this->entity = new AllowIPEntity();
	}
}