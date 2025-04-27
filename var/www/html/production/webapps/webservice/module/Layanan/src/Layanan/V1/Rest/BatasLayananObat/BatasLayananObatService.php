<?php
namespace Layanan\V1\Rest\BatasLayananObat;
use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;
use Laminas\Db\Sql\Select;
use Laminas\Db\Sql\Expression;
use DBService\System;
use Inventory\V1\Rest\Barang\BarangService;

class BatasLayananObatService extends Service
{
	private $barang;
	
    public function __construct() {
		$this->config["entityName"] = "Layanan\\V1\\Rest\\BatasLayananObat\\BatasLayananObatEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("batas_layanan_obat", "layanan"));
		$this->entity = new BatasLayananObatEntity();
		$this->barang = new BarangService();
    }
        
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		
		foreach($data as &$entity) {
			$barang = $this->barang->load(['ID' => $entity['FARMASI']]);
			if(count($barang) > 0) $entity['REFERENSI']['BARANG'] = $barang[0];
		}
		
		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'NORM')) { 
			$select->where(["NORM" => $params['NORM']]);
			unset($params['NORM']);
		}
		if(!System::isNull($params, 'FARMASI')) { 
			$select->where(["FARMASI" => $params['FARMASI']]);
			unset($params['FARMASI']);
		}
		if(!System::isNull($params, 'TANGGAL')) { 
			$select->where(["TANGGAL" => $params['TANGGAL']]);
			unset($params['TANGGAL']);
		}
		if(!System::isNull($params, 'BATAS')) { 
			$params[] = new \Laminas\Db\Sql\Predicate\Expression("TANGGAL >= ?", [$params["BATAS"]]);
			unset($params['BATAS']);
		}
	}
}