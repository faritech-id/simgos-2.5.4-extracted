<?php
namespace Dashboard\V1\Rpc\Indikator;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService {
	public function __construct($includeReferences = true, $references = []) {
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("indikator_rs", "informasi"));
	}

    public function getList($params) {
        $_params = [
            (isset($params["tglAwal"]) ? $params["tglAwal"] : date("Y-m-d")),
            (isset($params["tglAkhir"]) ? $params["tglAkhir"] : date("Y-m-d"))
        ];
        return $this->execute("CALL informasi.listIndikatorRS(?,?)", $_params);
    }

    public function getDataGrafik($params) {
        $_params = [
            (isset($params["tglAwal"]) ? $params["tglAwal"] : date("Y-m-d")),
            (isset($params["tglAkhir"]) ? $params["tglAkhir"] : date("Y-m-d"))
        ];
        return $this->execute("CALL informasi.listIndikatorRSGrafik(?,?)", $_params);
    } 
}