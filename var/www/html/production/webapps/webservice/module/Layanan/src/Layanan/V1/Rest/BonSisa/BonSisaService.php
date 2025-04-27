<?php
namespace Layanan\V1\Rest\BonSisa;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;
use Layanan\V1\Rest\Farmasi\FarmasiService;
use Inventory\V1\Rest\Barang\BarangService;
class BonSisaService extends Service
{
	private $layananfarmasi;
	private $barang;

    public function __construct() {
		$this->config["entityName"] = "Layanan\\V1\\Rest\\BonSisa\\BonSisaEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("bon_sisa_farmasi", "layanan"));
		$this->entity = new BonSisaEntity();
		
		$this->layananfarmasi = new FarmasiService();
        $this->barang = new BarangService();
    }
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		foreach($data as &$entity) {
            $barang = $this->barang->load(['ID' => $entity['FARMASI']]);
			if(count($barang) > 0) $entity['REFERENSI']['FARMASI'] = $barang[0];
			$layananfarmasi = $this->layananfarmasi->load(['ID' => $entity['REF']]);
			if(count($layananfarmasi) > 0) $entity['REFERENSI']['LAYANAN_FARMASI'] = $layananfarmasi[0];
            $entity['JUMLAH_LAYANAN'] = 0;
        }
				
		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'STATUS')) {
			$status = $params['STATUS'];
			$params['bon_sisa_farmasi.STATUS'] = $status;
			unset($params['STATUS']);
		}
		
		if(!System::isNull($params, 'KUNJUNGAN')) { 
			$select->join(
				['k' => new TableIdentifier('farmasi', 'layanan')],
				'k.ID = bon_sisa_farmasi.REF',
				['KUNJUNGAN']
			);
		}
		if(!System::isNull($params, 'ALL')) {
			unset($params['ALL']);
		}
	}
}
