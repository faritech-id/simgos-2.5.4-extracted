<?php
namespace DocumentStorage\V1\Rpc\Document;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

use DocumentStorage\V1\Rest\DocumentDirectory\Service as DDS;

class Service extends DBService {
	private $dds;

	public function __construct() {
		$this->config["entityName"] = "DocumentStorage\\V1\\Rpc\\Document\\Entity";
        $this->config["autoIncrement"] = false;
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("document", "document-storage"));
        $this->entity = new Entity();

		$this->dds = new DDS();
    }

	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);

		foreach($data as &$entity) {
			$result = $this->dds->load(['ID' => $entity['DOCUMENT_DIRECTORY_ID']]);
			if(count($result) > 0) $entity['REFERENSI']['DOCUMENT_DIRECTORY'] = $result[0];
		}
		
		return $data;
	}
}
