<?php
namespace Aplikasi\V1\Rest\Sinkronisasi;

use DBService\DatabaseService;
use DBService\Service as DBService;
use DBService\System;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;

class Service extends DBService
{
	public function __construct() {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("sinkronisasi", "aplikasi"));
		$this->entity = new SinkronisasiEntity();
    }
	
	public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;		
		$this->entity->exchangeArray($data);
		if(!isset($data['TANGGAL_TERAKHIR'])) $this->entity->set('TANGGAL_TERAKHIR', new \Laminas\Db\Sql\Expression('NOW()'));
		$id = $data["ID"];
		$sinkronisasi = $this->load(["ID" => $id]);
		if(count($sinkronisasi) > 0) {
			$this->table->update($this->entity->getArrayCopy(), ["ID" => $id]);
		} else {
			$this->table->insert($this->entity->getArrayCopy());
			$id = (int) $id;
			if($id == 0) $id = $this->table->getLastInsertValue();
		}
			
		return [
			'success' => true,
			'data' => $this->load(["ID" => $id])
		];
	}
}