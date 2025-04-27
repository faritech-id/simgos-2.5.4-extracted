<?php
namespace General\V1\Rest\JenisPesertaPenjamin;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;

class Service extends DBService {
	public function __construct() {
		$this->config["entityName"] = "General\\V1\\Rest\\JenisPesertaPenjamin\\JenisPesertaPenjaminEntity";
		$this->config["autoIncrement"] = false;
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("jenis_peserta_penjamin", "master"));		
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'QUERY')) { 
			$select->where->like("DESKRIPSI", $params['QUERY']."%");
			unset($params['QUERY']);
		}
	}
}