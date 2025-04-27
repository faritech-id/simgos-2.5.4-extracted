<?php
namespace Pegawai\V1\Rest\StrSip;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use Laminas\File\Transfer\Adapter\AbstractAdapter;
use Laminas\File\Transfer\Adapter\Http;
use DBService\System;
use DBService\Service as DBService;

class Service extends DBService {
	
	public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "Pegawai\\V1\\Rest\\StrSip\\StrSipEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("str_sip", "pegawai"));
		$this->entity = new StrSipEntity();
	}
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$isShowFile = isset($params["SHOW_FILE"])? true : false;
		unset($params["SHOW_FILE"]);
		$data = parent::load($params, $columns, $orders);
		
		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($isShowFile) {
					if($entity["FILE"]) $entity["FILE"] = $this->getFileContentFromBlob($entity["FILE"], $entity["TYPE"]);
				} else {
					unset($entity["FILE"]);
				}
			}
		}
		return $data;
	}

	protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
		if(isset($data["FILE"]) && !empty($data["FILE"])) {
			try {
				$file = $this->getFileContentFromPost($data["FILE"], ['application/pdf']);
				$entity->set("FILE", $file["content"]);
				$entity->set("TYPE", $file["tipe"]);
			} catch(\Exception $e) {
				//
			}
		}
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(isset($params['QUERY'])) if(!System::isNull($params, 'QUERY')){
			$select->where->like('NOMOR', '%'.$params['QUERY'].'%');
			unset($params['QUERY']);
		}
		
		if(isset($params['IDX'])) if(!System::isNull($params, 'IDX')){
			$select->where->like('ID', $params['IDX']);
			unset($params['IDX']);
		}
	}
}