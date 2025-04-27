<?php
namespace Inventory\V1\Rest\StokOpnameDetil;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;
use Inventory\V1\Rest\BarangRuangan\BarangRuanganService;

class StokOpnameDetilService extends Service
{
	private $barangruangan;
	
    public function __construct() {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("stok_opname_detil", "inventory"));
		$this->entity = new StokOpnameDetilEntity();
		
		$this->barangruangan = new BarangRuanganService();		
    }
	
	public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;
		$this->entity->exchangeArray($data);
		
		$stok_opname = $this->entity->get('STOK_OPNAME');
		$barang_ruangan = $this->entity->get('BARANG_RUANGAN');
		$tanggal = $this->entity->get('TANGGAL');
		
		$id = is_numeric($this->entity->get('ID')) ? $this->entity->get('ID') : 0;
		
		if($id == 0) {
			$this->table->insert($this->entity->getArrayCopy());
		} else {
			$this->table->update($this->entity->getArrayCopy(), ['ID'=>$id]);
		}
		
		return [
			'success' => true
		];
	}
	
	public function load($params = [], $columns = ['*'], $penjualans = []) {
		$data = parent::load($params, $columns, $penjualans);
		
		foreach($data as &$entity) {
			$barangruangan = $this->barangruangan->load(['ID' => $entity['BARANG_RUANGAN']]);
			if(count($barangruangan) > 0) $entity['REFERENSI']['BARANG_RUANGAN'] = $barangruangan[0];
		}
		
		return $data;
	}
	
	protected function queryCallback(Select &$select, &$params, $columns, $orders) {		
		if(!System::isNull($params, 'ID')) {
			$params['stok_opname_detil.ID'] = $params['ID'];
			unset($params['ID']);
		}
		
		$select->join(
			['br' => new TableIdentifier('barang_ruangan', 'inventory')],
			'br.ID = BARANG_RUANGAN',
			['BARANG' => 'BARANG']
		);
	
		$select->join(
			['b' => new TableIdentifier('barang', 'inventory')],
			'b.ID = BARANG',
			['NAMA' => 'NAMA']
		);
		
		if(!System::isNull($params, 'MANUAL')) { 
			if($params['MANUAL'] == "") {
				$select->where("MANUAL IS NULL");
				unset($params['MANUAL']);
			}
		}
			
		if(!System::isNull($params, 'QUERY')) { 
			$select->where->like("NAMA", "%".$params['QUERY']."%");
			unset($params['QUERY']);
		}
		
		if(!System::isNull($params, 'KATEGORI')) { 
			$select->where->like('KATEGORI', $params['KATEGORI'].'%');
			unset($params['KATEGORI']);
		}
	}
}
