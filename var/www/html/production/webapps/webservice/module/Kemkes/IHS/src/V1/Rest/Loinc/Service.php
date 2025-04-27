<?php
namespace Kemkes\IHS\V1\Rest\Loinc;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;

class Service extends DBService
{    
    public function __construct($includeReferences = true, $references = []) {
        $this->config["entityName"] = "Kemkes\\IHS\\V1\\Rest\\Loinc\\LoincEntity";
        $this->config["autoIncrement"] = false;
        $this->config["entityId"] = "id";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("loinc_terminologi", "kemkes-ihs"));
        $this->entity = new LoincEntity();
    }

    protected function queryCallback(Select &$select, &$params, $columns, $orders) {
        if(!System::isNull($params, 'query')) {
            $params[] = new \Laminas\Db\Sql\Predicate\Expression("(Kategori_pemeriksaan LIKE ? OR nama_pemeriksaan LIKE ? OR code LIKE ?)", ["%".$params["query"]."%", "%".$params["query"]."%", "%".$params["query"]."%"]);
			unset($params['query']);
		}
    }
}