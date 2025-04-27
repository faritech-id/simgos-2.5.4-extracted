<?php
namespace Pembayaran\V1\Rest\PiutangPasien;

use DBService\DatabaseService;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;
use Laminas\Db\Sql\TableIdentifier;

use General\V1\Rest\Referensi\ReferensiService;

class PiutangPasienService extends Service
{
	private $referensi; 
	
    public function __construct() {
		$this->config["entityName"] = "Pembayaran\\V1\\Rest\\PiutangPasien\\PiutangPasienEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("piutang_pasien", "pembayaran"));
		$this->entity = new PiutangPasienEntity();
		
		$this->referensi = new ReferensiService();
    }
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
			foreach($data as &$entity) {
				$shdk = $this->referensi->load(['ID' => $entity['SHDK'], 'JENIS' => 7]);
				if(count($shdk) > 0) $entity['REFERENSI']['SHDK'] = $shdk[0];
				
				$jeniskartu = $this->referensi->load(['ID' => $entity['JENIS_KARTU'], 'JENIS' => 9]);
				if(count($jeniskartu) > 0) $entity['REFERENSI']['JENIS_KARTU'] = $jeniskartu[0];

			}

		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'NORM')) {
			$select->join(['t'=>new TableIdentifier('tagihan', 'pembayaran')], 't.ID = TAGIHAN', []);
			$select->where('t.REF = '.$params['NORM'].' AND t.JENIS = 1');
			
			unset($params['NORM']);
			
			if(!System::isNull($params, 'STATUS')){
				$select->where('piutang_pasien.STATUS = '.$params['STATUS']);
				unset($params['STATUS']);
			}
		}
	}	
	
}
