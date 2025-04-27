<?php
namespace Plugins\db\bpjs\rencanakontrol;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;

class Service extends DBService {
	public function __construct() {
        $this->config["entityName"] = "\\Plugins\\db\\bpjs\\rencanakontrol\\Entity";
        $this->config["entityId"] = "noSuratKontrol";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("monitoring_rencana_kontrol", "bpjs"));
		$this->entity = new Entity();
    }
    public function simpan($data) {
		$this->entity->exchangeArray($data);
        $noSuratKontrol = $this->entity->get('noSuratKontrol') ? $this->entity->get('noSuratKontrol') : '0';
        $cek = $this->table->select(["noSuratKontrol" => $noSuratKontrol])->toArray();
        if(count($cek) > 0) {
            $_data = $this->entity->getArrayCopy();
            $this->table->update($_data, ["noSuratKontrol" => $noSuratKontrol]);
        } else {
            $this->table->insert($this->entity->getArrayCopy());
        }
		return array(
			'success' => true,
			'data' => $data
		);
	}

    public function queryCallback(Select &$select, &$params, $columns, $orders) {
			
		if(!System::isNull($params, 'tanggal')) {
            $select->where("tanggal = ".$params['tanggal']);
			unset($params['tanggal']);
		}
	}
}