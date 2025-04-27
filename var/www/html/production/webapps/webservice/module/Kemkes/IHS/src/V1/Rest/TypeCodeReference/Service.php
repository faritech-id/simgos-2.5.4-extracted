<?php
namespace Kemkes\IHS\V1\Rest\TypeCodeReference;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System; 
use DBService\Service as DBService;

class Service extends DBService
{    
    public function __construct($includeReferences = true, $references = []) {
        $this->config["entityName"] = "Kemkes\\IHS\\V1\\Rest\\TypeCodeReference\\TypeCodeReferenceEntity";
        $this->config["autoIncrement"] = false;
        $this->config["entityId"] = "id";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("type_code_reference", "kemkes-ihs"));
        $this->entity = new TypeCodeReferenceEntity();
    }

    public function simpanData($data, $isCreated = false, $loaded = true) {
	    $data = is_array($data) ? $data : (array) $data;
	    $entity = $this->config["entityName"];
	    $this->entity = new $entity();
	    $this->entity->exchangeArray($data);
	    if($isCreated) {
	        $this->table->insert($this->entity->getArrayCopy());
            $id = $this->table->getLastInsertValue();
            $type = $this->entity->get("type");
	    } else {
	        $id = $this->entity->get("id");
            $type = $this->entity->get("type");
	        $this->table->update($this->entity->getArrayCopy(), ["id" => $id, "type" => $type]);
	    }
		
	    if($loaded) {
			$tableName = $this->getTableName();
			return $this->load([$tableName.".id" => $id, $tableName.".type" => $type]);
		}
	    return $id;
	}

    protected function queryCallback(Select &$select, &$params, $columns, $orders) {
        if(!System::isNull($params, 'display')) {
			$params[] = new \Laminas\Db\Sql\Predicate\Expression("(code = ? OR display LIKE ?)", [$params["display"], "%".$params["display"]."%"]);
			unset($params['display']);
		}
    }
}