<?php
namespace Pembatalan\V1\Rest\FinalHasil;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService {
	public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "Pembatalan\\V1\\Rest\\FinalHasil\\FinalHasilEntity";		
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("pembatalan_final_hasil", "pembatalan"));				
	}	
}