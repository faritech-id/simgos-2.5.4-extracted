<?php
namespace Dashboard\V1\Rpc\RawatInap;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService {
	public function __construct($includeReferences = true, $references = []) {
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("pasien_rawat_inap", "informasi"));
	}

    public function getList($params) {
        $_params = [
            (isset($params["tglAwal"]) ? $params["tglAwal"] : date("Y-m-d")),
            (isset($params["tglAkhir"]) ? $params["tglAkhir"] : date("Y-m-d")),
            (isset($params["type"]) ? $params["type"] : 9)
        ];
        $data = [];
        $result = $this->execute("CALL informasi.listPasienMasuk(?,?,?)", $_params);
        $data = $result;
        $result = $this->execute("CALL informasi.listPasienRawat(?,?,?)", $_params);
        $data = array_merge($data, $result);
        $result = $this->execute("CALL informasi.listPasienKeluar(?,?,?)", $_params);
        $data = array_merge($data, $result);
        return $data;
    }
}