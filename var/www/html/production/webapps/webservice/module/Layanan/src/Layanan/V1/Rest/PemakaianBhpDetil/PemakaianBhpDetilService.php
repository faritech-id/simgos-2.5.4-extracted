<?php
namespace Layanan\V1\Rest\PemakaianBhpDetil;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;

use Inventory\V1\Rest\Barang\BarangService;

class PemakaianBhpDetilService extends Service
{
	private $barang;
	
    public function __construct() {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("pemakaian_bhp_detil", "layanan"));
		$this->entity = new PemakaianBhpDetilEntity();
		$this->barang = new BarangService();		
    }
	
	public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;
		$this->entity->exchangeArray($data);
		$id = is_numeric($this->entity->get('ID')) ? $this->entity->get('ID') : 0;
		if(isset($data['DELETE'])) {
			return $this->deleteRow($id);
		} else {
			if($id > 0) {
				if($this->entity->get('JUMLAH') > 0){
					$this->table->update($this->entity->getArrayCopy(), array("ID" => $id));
				}
			} else {
				if($this->entity->get('JUMLAH') > 0){
					$this->table->insert($this->entity->getArrayCopy());
				}
			}
			return array(
				'success' => true
			);
		}
	}
	public function deleteRow($nomor) {
		$adapter = $this->table->getAdapter();
		$stmt = $adapter->query("DELETE FROM layanan.pemakaian_bhp_detil WHERE ID = $nomor AND STATUS = 1");
		if($stmt->execute()){
			return array(
				'success' => true
			);
		} else {
			return array(
				'success' => false,
				'message' => "Gagal Hapus Row"
			);
		}
	}
	public function load($params = array(), $columns = array('*'), $penjualans = array()) {
		$data = parent::load($params, $columns, $penjualans);
		
		foreach($data as &$entity) {			
			$barang = $this->barang->load(array('ID' => $entity['BARANG']));
			if(count($barang) > 0) $entity['REFERENSI']['BARANG'] = $barang[0];			
		}
		
		return $data;
	}
	
	protected function query($columns, $params, $isCount = false, $orders = array()) {		
		$params = is_array($params) ? $params : (array) $params;		
		return $this->table->select(function(Select $select) use ($isCount, $params, $columns, $orders) {
			if($isCount) $select->columns(array('rows' => new \Laminas\Db\Sql\Expression('COUNT(1)')));
			else if(!$isCount) $select->columns($columns);
			
			if(!System::isNull($params, 'start') && !System::isNull($params, 'limit')) {	
				$select->offset((int) $params['start'])->limit((int) $params['limit']);
				unset($params['start']);
				unset($params['limit']);
			}// else $select->offset(0)->limit($this->limit); //Hapus Limit
			
			$select->where($params);
			$select->order($orders);
		})->toArray();
	}
}
