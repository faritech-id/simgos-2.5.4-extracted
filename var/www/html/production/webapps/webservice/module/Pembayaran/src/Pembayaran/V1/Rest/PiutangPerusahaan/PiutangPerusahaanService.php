<?php
namespace Pembayaran\V1\Rest\PiutangPerusahaan;

use DBService\DatabaseService;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;
use Laminas\Db\Sql\TableIdentifier;

use General\V1\Rest\Referensi\ReferensiService;

class PiutangPerusahaanService extends Service
{
	private $referensi;
	
    public function __construct() {
		$this->config["entityName"] = "Pembayaran\\V1\\Rest\\PiutangPerusahaan\\PiutangPerusahaanEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("piutang_perusahaan", "pembayaran"));
		$this->entity = new PiutangPerusahaanEntity();
		
		$this->referensi = new ReferensiService();
    }
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);		
		foreach($data as &$entity) {
			$penjamin = $this->referensi->load(['JENIS' => 10, 'ID' => $entity['PENJAMIN']]);
			if(count($penjamin) > 0) $entity['REFERENSI']['PENJAMIN'] = $penjamin[0];
		}
		
		return $data;
	}
	
	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'NORM')) {
			$select->join(['t'=>new TableIdentifier('tagihan', 'pembayaran')], 't.ID = TAGIHAN', []);
			$select->where('t.REF = '.$params['NORM'].' AND t.JENIS = 1');
			unset($params['NORM']);
			if(!System::isNull($params, 'STATUS')){
				$select->where('piutang_perusahaan.STATUS = '.$params['STATUS']);
				unset($params['STATUS']);
			}
		}
	}
}
