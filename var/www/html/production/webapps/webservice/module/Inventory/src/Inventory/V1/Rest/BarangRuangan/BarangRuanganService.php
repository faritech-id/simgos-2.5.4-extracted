<?php
namespace Inventory\V1\Rest\BarangRuangan;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;

use Inventory\V1\Rest\Barang\BarangService;
use Inventory\V1\Rest\NoSeriBarangRuangan\Service as NoSeriBarangRuanganService;
use General\V1\Rest\Ruangan\RuanganService;

class BarangRuanganService extends Service
{
	private $barang;
	private $NoSeriBarangRuangan;
	private $Ruangan;
	
    public function __construct() {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("barang_ruangan", "inventory"));
		$this->entity = new BarangRuanganEntity();
		
		$this->barang = new BarangService();		
		$this->NoSeriBarangRuangan = new NoSeriBarangRuanganService();		
		$this->Ruangan = new RuanganService();		
    }
	
	public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;
		$this->entity->exchangeArray($data);
		$id = (int) $this->entity->get('ID');
		
		//if (isset($data["NO_SERI_BARANG_RUANGAN"])) {
		if (isset($data["NO_SERI_BARANG_RUANGAN"])) {
			$stokBaru = $this->entity->get('STOK');
			$barangRuangan = isset($data['BARANG_RUANGAN']['RUANGAN']);
			$idRuangan = $this->entity->get('RUANGAN');
			$idBarang = $this->entity->get('BARANG');
			$strLmt = "SELECT RUANGAN, STOK FROM inventory.barang_ruangan WHERE RUANGAN = '".$idRuangan."' AND BARANG = '".$idBarang."'";
			$queryLmt = $this->execute($strLmt);
			$ruangan = floatval(isset($queryLmt[0]['RUANGAN'])?$queryLmt[0]['RUANGAN']:0);
			
			if ($ruangan == 0 && $barangRuangan) {
				$this->table->insert($this->entity->getArrayCopy());
				$id = $this->table->getLastInsertValue();
				
				$br1 = $data['BARANG_RUANGAN']['RUANGAN'];
				$strLmt5 = "SELECT RUANGAN, STOK FROM inventory.barang_ruangan WHERE RUANGAN = '".$br1."' AND BARANG = '".$idBarang."'";
				$queryLmt5 = $this->execute($strLmt5);
				$stokruangan = floatval(isset($queryLmt5[0]['STOK'])?$queryLmt5[0]['STOK']:0);
				$strLmt6 = "UPDATE inventory.barang_ruangan 
							SET STOK = '".$stokruangan."'-'".$stokBaru."'
							WHERE RUANGAN = '".$br1."' AND BARANG = '".$idBarang."'";
				$queryLmt6 = $this->execute($strLmt6);
				
				//$this->UpdateBarangRuangan($data);
				$this->SimpanNoSeriBarangRuangan($data, $id);
			}
			else {
				
				$br2 = $data['BARANG_RUANGAN']['RUANGAN'];
				$strLmt2 = "SELECT RUANGAN, STOK FROM inventory.barang_ruangan WHERE RUANGAN = '".$br2."' AND BARANG = '".$idBarang."'";
				$queryLmt2 = $this->execute($strLmt2);
				$stokruangan1 = floatval(isset($queryLmt2[0]['STOK'])?$queryLmt2[0]['STOK']:0);
				$stok = floatval(isset($queryLmt[0]['STOK'])?$queryLmt[0]['STOK']:0);
				
				$strLmt1 = "UPDATE inventory.barang_ruangan 
							SET STOK = '".$stokBaru."'+'".$stok."'
							WHERE RUANGAN = '".$idRuangan."' AND BARANG = '".$idBarang."'";
				$queryLmt1 = $this->execute($strLmt1);
				$strLmt3 = "UPDATE inventory.barang_ruangan 
							SET STOK = '".$stokruangan1."'-'".$stokBaru."'
							WHERE RUANGAN = '".$br2."' AND BARANG = '".$idBarang."'";
				$queryLmt3 = $this->execute($strLmt3);
				$strLmt4 = "SELECT ID FROM inventory.barang_ruangan WHERE RUANGAN = '".$idRuangan."' AND BARANG = '".$idBarang."'";
				$queryLmt4 = $this->execute($strLmt4);
				$idbarangruangan = floatval(isset($queryLmt4[0]['ID'])?$queryLmt4[0]['ID']:0);
				$this->UpdateNoSeriBarangRuangan($data, $idbarangruangan);
			}
		}
		else {
			if($id > 0){
				$this->table->update($this->entity->getArrayCopy(), ["ID" => $id]);
			} else {
				$this->table->insert($this->entity->getArrayCopy());
				$id = $this->table->getLastInsertValue();
			}
		}
		
		return [
			'success' => true
		];
	}
	
	/* public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;
		$this->entity->exchangeArray($data);
		$id = (int) $this->entity->get('ID');
		
		if($id > 0){
			$this->table->update($this->entity->getArrayCopy(), array("ID" => $id));
		} else {
			$this->table->insert($this->entity->getArrayCopy());
			$id = $this->table->getLastInsertValue();
		}
		
		return array(
			'success' => true
		);
	} */
	
	/* private function UpdateBarangRuangan($data) {
		if(isset($data['BARANG_RUANGAN'])) {
			$data = is_array($data['BARANG_RUANGAN']) ? $data['BARANG_RUANGAN'] : (array) $data['BARANG_RUANGAN'];
			$this->simpan($data);
		}
	} */
	
	private function SimpanNoSeriBarangRuangan($data, $id) {
		if(isset($data['NO_SERI_BARANG_RUANGAN'])) {
			
			foreach($data['NO_SERI_BARANG_RUANGAN'] as $dtl) {
				$dtl['BARANG_RUANGAN'] = $id;
				$this->NoSeriBarangRuangan->simpan($dtl);
			}
		}
	}
	
	private function UpdateNoSeriBarangRuangan($data, $id) {
		if(isset($data['NO_SERI_BARANG_RUANGAN'])) {
			
			foreach($data['NO_SERI_BARANG_RUANGAN'] as $dtl) {
				$dtl['BARANG_RUANGAN'] = $id;
				$this->NoSeriBarangRuangan->simpan($dtl);
			}
		}
	}
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		foreach($data as &$entity) {
			$barang = $this->barang->load(['ID' => $entity['BARANG']]);
			if(count($barang) > 0) $entity['REFERENSI']['BARANG'] = $barang[0];
			
			$Ruangan = $this->Ruangan->load(['ID' => $entity['RUANGAN']]);
			if(count($Ruangan) > 0) $entity['REFERENSI']['RUANGAN'] = $Ruangan[0];
		}
		return $data;
	}

	protected function query($columns, $params, $isCount = false, $orders = []) {		
		$params = is_array($params) ? $params : (array) $params;		
		return $this->table->select(function(Select $select) use ($isCount, $params, $columns, $orders) {
			if($isCount) $select->columns(['rows' => new \Laminas\Db\Sql\Expression('COUNT(1)')]);
			else if(!$isCount) $select->columns($columns);
			
			if(!System::isNull($params, 'start') && !System::isNull($params, 'limit')) {	
				$select->offset((int) $params['start'])->limit((int) $params['limit']);
				unset($params['start']);
				unset($params['limit']);
			} else {
				if(isset($params['RUANGAN_DISTRIBUSI_BARANG'])) {
					$select->limit($this->limit);
					unset($params['RUANGAN_DISTRIBUSI_BARANG']);
				}
				else {
					$select->offset(0)->limit($this->limit);
				}
			}

			$this->queryCallback($select, $params, $columns, $orders);

			foreach($params as $key => $val) {
				$predicate = $this->getPredicateParams($key, $val);
				if($predicate) {
					$params[] = $predicate;
					unset($params[$key]);
				}
			}
				
			$select->where($params);
			$select->order($orders);
		})->toArray();
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'STATUS')) {
			$status = $params['STATUS'];
			$params['barang_ruangan.STATUS'] = $status;
			unset($params['STATUS']);
		}

		if(!System::isNull($params, 'STOK')) {
			$_params = $params['STOK'];
			$params['barang_ruangan.STOK'] = $_params;
			unset($params['STOK']);
		}
		
		$kategori = "";
		if(isset($params['KATEGORI_BARANG'])) {
			if(!System::isNull($params, 'KATEGORI_BARANG')) {
				$kategori = $params['KATEGORI_BARANG'];
				unset($params['KATEGORI_BARANG']);
			}
		}
		
		if(isset($params['KATEGORI_BARANG_INFEKSI'])) {
			if(!System::isNull($params, 'KATEGORI_BARANG_INFEKSI')) {
				$kategori = $params['KATEGORI_BARANG_INFEKSI'];
				unset($params['KATEGORI_BARANG_INFEKSI']);
			}
		}
		
		if(isset($params['KATEGORI_BARANG_NON_INFEKSI'])) {
			if(!System::isNull($params, 'KATEGORI_BARANG_NON_INFEKSI')) {
				$kategori = $params['KATEGORI_BARANG_NON_INFEKSI'];
				unset($params['KATEGORI_BARANG_NON_INFEKSI']);
			}
		}

		if(!System::isNull($params, 'KATEGORI')) {
			$kategori = $params['KATEGORI'];
			unset($params['KATEGORI']);
		}

		if($kategori != "") {
			$select->join(['d' => new TableIdentifier("barang", "inventory")], "barang_ruangan.BARANG = d.ID", []);
			$select->where->like('d.KATEGORI', $kategori['d.KATEGORI'].'%');
		}
		
		if(isset($params['CEKSTOK'])) {
			if(!System::isNull($params, 'CEKSTOK')) { 
				$select->where("STOK != '0'");
				unset($params['CEKSTOK']);
			}
		}
		if(isset($params['BARANG'])) {
			if(!System::isNull($params, 'BARANG')) { 
				$select->where(["BARANG" => $params['BARANG']]);
				unset($params['BARANG']);
			}
		}
		if(isset($params['RUANGAN'])) {
			if(!System::isNull($params, 'RUANGAN')) { 
				$select->where(["RUANGAN" => $params['RUANGAN']]);
				unset($params['RUANGAN']);
			}
		}
		if(isset($params['QUERY'])) {
			if(!System::isNull($params, 'QUERY')) {
				$select->join(['c' => new TableIdentifier("barang", "inventory")], "barang_ruangan.BARANG = c.ID", []);
				$select->where->like('c.NAMA', '%'.$params['QUERY'].'%');
				unset($params['QUERY']);
			}
		}
		
		if(isset($params['JENIS_GENERIK'])) {
			if(!System::isNull($params, 'JENIS_GENERIK')) {
				$select->join(['d' => new TableIdentifier("barang", "inventory")], "barang_ruangan.BARANG = d.ID", []);
				$select->where(["d.JENIS_GENERIK" => $params['JENIS_GENERIK']]);
				//$select->where("d.JENIS_GENERIK IN (0,1,2)");
				unset($params['JENIS_GENERIK']);
			}
		}
		
		if(isset($params['RUANGAN_DISTRIBUSI_BARANG'])) {
			if(!System::isNull($params, 'RUANGAN_DISTRIBUSI_BARANG')) {
				$select->join(['d' => new TableIdentifier("no_seri_barang_ruangan", "inventory")], "barang_ruangan.ID = d.BARANG_RUANGAN", []);
				$select->where(["barang_ruangan.RUANGAN" => $params['RUANGAN_DISTRIBUSI_BARANG']]);
				$select->group("barang_ruangan.RUANGAN");
				unset($params['RUANGAN_DISTRIBUSI_BARANG']);
			}
		}
		if(isset($params['BARANG_RS'])) {
			if(!System::isNull($params, 'BARANG_RS')) {
				unset($params['BARANG_RS']);
			}
		}
	}
}
