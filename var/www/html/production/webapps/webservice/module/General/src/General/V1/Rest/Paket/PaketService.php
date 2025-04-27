<?php
namespace General\V1\Rest\Paket;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;
use General\V1\Rest\Referensi\ReferensiService;

class PaketService extends Service
{
	private $referensi;
    public function __construct() {
		$this->config["entityName"] = "General\\V1\\Rest\\Paket\\PaketEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("paket", "master"));
		$this->entity = new PaketEntity();
		$this->referensi = new ReferensiService();
    }
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);

		if($this->includeReferences) {
			foreach($data as &$entity) {
				$referensi = $this->referensi->load(['ID' => $entity['KELAS'], 'JENIS' => 19]);
				if(count($referensi) > 0) $entity['REFERENSI']['KELAS'] = $referensi[0];
			}
		}
		return $data;
	}
	
	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'UNTUK_KUNJUNGAN')) {
			$select->where('FIND_IN_SET('.$params['UNTUK_KUNJUNGAN'].',UNTUK_KUNJUNGAN) > 0');
			unset($params['UNTUK_KUNJUNGAN']);
		}
	}
}