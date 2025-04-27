<?php
namespace Aplikasi\V1\Rest\PropertiConfig;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService {
	public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "Aplikasi\\V1\\Rest\\PropertiConfig\\PropertiConfigEntity";		
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("properti_config", "aplikasi"));
		$this->limit = 1000;
		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {
			// deklarasikan dengan membuat object referensi
			//if($this->references['Referensi']) $this->referensi = new ReferensiService();
		}
	}	
}