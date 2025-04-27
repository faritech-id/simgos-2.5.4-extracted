<?php
namespace Kemkes\IHS\V1\Rest\POA;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use Kemkes\IHS\V1\Rest\TypeCodeReference\Service as typeCodeService;

class Service extends DBService
{    
    private $typecode;
    public function __construct($includeReferences = true, $references = []) {
        $this->config["entityName"] = "Kemkes\\IHS\\V1\\Rest\\POA\\POAEntity";
        $this->config["autoIncrement"] = false;
        $this->config["entityId"] = "id";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("poa", "kemkes-ihs"));
        $this->entity = new POAEntity();
        $this->typecode = new typeCodeService();
    }

    public function load($params = array(), $columns = array('*'), $orders = array()) {
		$data = parent::load($params, $columns, $orders);
		foreach($data as &$entity) {
            $st = $this->typecode->load(['type' => 15, 'id' => $entity['id_bentuk_sediaan']]);
			if(count($st) > 0) $entity['REFERENSI']['BENTUK_SEDIAAN'] = $st[0];
		}
				
		return $data;
	}

    protected function queryCallback(Select &$select, &$params, $columns, $orders) {
        if(!System::isNull($params, 'display')) {
            $select->where->like('display', '%'.$params['display'].'%');
            unset($params['display']);
		}

         if(!System::isNull($params, 'query')) {
			$params[] = new \Laminas\Db\Sql\Predicate\Expression("(id = ? OR display LIKE ?)", [$params["query"], "%".$params["query"]."%"]);
			unset($params['query']);
		}
    }

    protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
        if(isset($data["BENTUK_SEDIAAN_KFA"])) {
            $sediaan = $this->saveTypeReverensi($data["BENTUK_SEDIAAN_KFA"]);
            $entity['id_bentuk_sediaan'] = $sediaan['id'];
        }
    }
 
    private function saveTypeReverensi($data){
        $data = $this->typecode->simpanData($data, isset($data->id) ? false : true);
        return $data[0];
    }

}