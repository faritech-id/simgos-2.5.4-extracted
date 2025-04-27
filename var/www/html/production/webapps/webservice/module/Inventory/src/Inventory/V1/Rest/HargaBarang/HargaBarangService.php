<?php
namespace Inventory\V1\Rest\HargaBarang;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;

use Inventory\V1\Rest\Barang\BarangService;

class HargaBarangService extends Service
{	
	private $barang;
	
	protected $references = [
		'Barang' => true
	];
	
    public function __construct($includeReferences = true, $references = []) {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("harga_barang", "inventory"));
		$this->entity = new HargaBarangEntity();
		
		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {
			if($this->references['Barang']) $this->barang = new BarangService();
		}
    }
	
	public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;
		$this->entity->exchangeArray($data);
		$id = (int) $this->entity->get('ID');
		
		if($id > 0){
			$this->table->update($this->entity->getArrayCopy(), ["ID" => $id]);
		} else {
			$this->table->insert($this->entity->getArrayCopy());
		}
		
		return [
			'success' => true
		];
	}
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['Barang']) {
					$barang = $this->barang->load(['ID' => $entity['BARANG']]);
					if(count($barang) > 0) $entity['REFERENSI']['BARANG'] = $barang[0];
				}
			}
		}
				
		return $data;
	}
}
