<?php
namespace Pembayaran\V1\Rest\GabungTagihan;

use DBService\DatabaseService;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;
use Laminas\Db\Sql\TableIdentifier;

class GabungTagihanService extends Service
{
    public function __construct() {
		$this->config["entityName"] = "Pembayaran\\V1\\Rest\\GabungTagihan\\GabungTagihanEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("gabung_tagihan", "pembayaran"));
		$this->entity = new GabungTagihanEntity();
    }

	protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
		$this->entity->set('TANGGAL', new \Laminas\Db\Sql\Expression('NOW()'));
	}
	
	public function hapus($id) {
		$this->table->delete(['ID'=>$id]);
		return true;
	}
	 
	public function batalGabungTagihan($tagihan) {
		$adapter = $this->table->getAdapter();
		$stmt = $adapter->query('CALL pembayaran.batalGabungTagihan(?)');
		$results = $stmt->execute([$tagihan]);
		$results->getResource()->closeCursor();
		return [
			'success' => true
		];
	}

	public function cekGabungTagihanBerdasakanNopen($nopen) {
		$result = $this->execute("SELECT pembayaran.cekGabungTagihanBerdasarkanNopen(?) CEK", [$nopen]);
		if(count($result) > 0) {
			if($result[0]["CEK"] == 1) return true;
		}
		return false;
	}
}
