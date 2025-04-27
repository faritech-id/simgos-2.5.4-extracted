<?php
namespace Dashboard\V1\Rpc\Penerimaan;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService {
	public function __construct($includeReferences = true, $references = []) {
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("penerimaan", "informasi"));
	}

    public function getList($params) {
        $_params = [
            (isset($params["tglAwal"]) ? $params["tglAwal"] : date("Y-m-d")),
            (isset($params["tglAkhir"]) ? $params["tglAkhir"] : date("Y-m-d")),
            (isset($params["type"]) ? $params["type"] : 9)
        ];
        return $this->execute("CALL informasi.listPenerimaanBank(?,?,?)", $_params);
    }
}