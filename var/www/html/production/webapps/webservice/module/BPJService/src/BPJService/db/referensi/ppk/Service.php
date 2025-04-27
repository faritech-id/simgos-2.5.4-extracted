<?php
namespace BPJService\db\referensi\ppk;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;
use DBService\System;
use Laminas\Db\Sql\Select;

class Service extends DBService {
	private $peserta;
	
	public function __construct() {
        $this->table = DatabaseService::get('BPJS')->get(new TableIdentifier("ppk", "bpjs"));
    }

    public function simpan($data, $isCreated = false, $loaded = false) {
		$data = is_array($data) ? $data : (array) $data;
		$this->entity = new Entity();
		$this->entity->exchangeArray($data);
		$params = array(
			"kode" => $data["kode"]
		);
		if($isCreated) {
			$this->table->insert($this->entity->getArrayCopy());
		} else {
			$this->table->update($this->entity->getArrayCopy(), $params);
		}
		
		if($loaded) return $this->load($params);
		return true;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'query')) {
			$params[] = new \Laminas\Db\Sql\Predicate\Expression("(kode = ? OR nama LIKE ?)", [$params["query"], "%".$params["query"]."%"]);
			unset($params["query"]);
		}
	}	
}