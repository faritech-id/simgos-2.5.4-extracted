<?php
namespace DocumentStorage\V1\Rest\DocumentDirectory;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService {
	public function __construct() {
		$this->config["entityName"] = "DocumentStorage\\V1\\Rest\\DocumentDirectory\\DocumentDirectoryEntity";
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("document_directory", "document-storage"));
        $this->entity = new DocumentDirectoryEntity();
    }
}
