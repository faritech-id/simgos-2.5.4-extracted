<?php
namespace Inventory\V1\Rest\NoSeriBarangRuangan;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;

//use Inventory\V1\Rest\BarangRuangan\BarangRuanganService;
//use Laundry\V1\Rest\PenerimaanNoSeriBarang\Service as PenerimaanNoSeriBarangService;
//use Laundry\V1\Rest\DistribusiNoSeriBarang\Service as DistribusiNoSeriBarangService;

class Service extends DBService {
	
	//private $BarangRuangan;
	//private $PenerimaanNoSeriBarang;
	//private $DistribusiNoSeriBarang;
	
	public function __construct() {
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("no_seri_barang_ruangan", "inventory"));
		$this->entity = new NoSeriBarangRuanganEntity();
		
		//$this->BarangRuangan = new BarangRuanganService();
		//$this->PenerimaanNoSeriBarang = new PenerimaanNoSeriBarangService();
		//$this->DistribusiNoSeriBarang = new DistribusiNoSeriBarangService();
	}
	
	public function load($params = array(), $columns = array('*'), $payroll = array()) {
		$data = parent::load($params, $columns, $payroll);
		
		foreach($data as &$entity) {
			/* $BarangRuangan = $this->BarangRuangan->load(array('ID' => $entity['BARANG_RUANGAN']));
			if(count($BarangRuangan) > 0) $entity['REFERENSI']['BARANG_RUANGAN'] = $BarangRuangan[0]; */
			
			/* $PenerimaanNoSeriBarang = $this->PenerimaanNoSeriBarang->load(array('NO_SERI_BARANG_RUANGAN' => $entity['ID']));
			if(count($PenerimaanNoSeriBarang) > 0) $entity['REFERENSI']['PENERIMAANNOSERIBARANG'] = $PenerimaanNoSeriBarang[0];
			
			if ($entity['REFERENSI']['PENERIMAANNOSERIBARANG']) {
				if ($entity['REFERENSI']['PENERIMAANNOSERIBARANG']['STATUS']) {
					$entity['STATUSPENERIMAANNOSERIBARANG'] = $entity['REFERENSI']['PENERIMAANNOSERIBARANG']['STATUS'];
				}
			}
			
			$DistribusiNoSeriBarang = $this->DistribusiNoSeriBarang->load(array('NO_SERI_BARANG_RUANGAN' => $entity['ID']));
			if(count($DistribusiNoSeriBarang) > 0) $entity['REFERENSI']['DISTRIBUSINOSERIBARANG'] = $DistribusiNoSeriBarang[0];
			
			if ($entity['REFERENSI']['DISTRIBUSINOSERIBARANG']) {
				if ($entity['REFERENSI']['DISTRIBUSINOSERIBARANG']['STATUS']) {
					$entity['STATUSDISTRIBUSINOSERIBARANG'] = $entity['REFERENSI']['DISTRIBUSINOSERIBARANG']['STATUS'];
				}
			} */
		}
		
		return $data;
	}
	
	protected function query($columns, $params, $isCount = false, $orders = array()) {		
		$params = is_array($params) ? $params : (array) $params;		
		return $this->table->select(function(Select $select) use ($isCount, $params, $columns, $orders) {
			if($isCount) $select->columns(array('rows' => new \Laminas\Db\Sql\Expression('COUNT(1)')));
			else if(!$isCount) $select->columns($columns);
			
			if(!System::isNull($params, 'start') && !System::isNull($params, 'limit')) {	
				if(!$isCount) $select->offset((int) $params['start'])->limit((int) $params['limit']);
				unset($params['start']);
				unset($params['limit']);
			} else $select->offset(0)->limit($this->limit);
			
			if(isset($params['STATUS'])) {
				if(!System::isNull($params, 'STATUS')) {
					$select->where("no_seri_barang_ruangan.STATUS IN (".$params['STATUS'].")");
					unset($params['STATUS']);
				}
			}
			
			if(isset($params['KONDISI_BARANG'])) {
				if(!System::isNull($params, 'KONDISI_BARANG')) {
					$select->where("no_seri_barang_ruangan.KONDISI_BARANG IN (".$params['KONDISI_BARANG'].")");
					unset($params['KONDISI_BARANG']);
				}
			}
			
			if(isset($params['KONDISI_BARANG_PENERIMAAN']) && isset($params['STATUS_PENERIMAAN']) && isset($params['PENERIMAAN_DETIL_LINEN'])) {
				if(!System::isNull($params, 'KONDISI_BARANG_PENERIMAAN', 'STATUS_PENERIMAAN', 'PENERIMAAN_DETIL_LINEN')) {
					$select->join(array('a' => new TableIdentifier("penerimaan_no_seri_barang", "laundry")), "no_seri_barang_ruangan.ID = a.NO_SERI_BARANG_RUANGAN", array());
					$select->join(array('b' => new TableIdentifier("penerimaan_detil_linen", "laundry")), "a.PENERIMAAN_DETIL_LINEN = b.ID", array());
					$select->where("no_seri_barang_ruangan.KONDISI_BARANG IN (".$params['KONDISI_BARANG_PENERIMAAN'].")
					AND no_seri_barang_ruangan.STATUS IN (".$params['STATUS_PENERIMAAN'].")
					AND a.PENERIMAAN_DETIL_LINEN IN (".$params['PENERIMAAN_DETIL_LINEN'].")");
					unset($params['KONDISI_BARANG_PENERIMAAN']);
					unset($params['STATUS_PENERIMAAN']);
					unset($params['PENERIMAAN_DETIL_LINEN']);
				}
			}
			
			if(isset($params['KONDISI_BARANG_PENERIMAAN_FINAL']) && isset($params['STATUS_PENERIMAAN_FINAL']) && isset($params['PENERIMAAN_DETIL_LINEN'])) {
				if(!System::isNull($params, 'KONDISI_BARANG_PENERIMAAN_FINAL', 'STATUS_PENERIMAAN_FINAL', 'PENERIMAAN_DETIL_LINEN')) {
					$select->join(array('a' => new TableIdentifier("penerimaan_no_seri_barang", "laundry")), "no_seri_barang_ruangan.ID = a.NO_SERI_BARANG_RUANGAN", array());
					$select->join(array('b' => new TableIdentifier("penerimaan_detil_linen", "laundry")), "a.PENERIMAAN_DETIL_LINEN = b.ID", array());
					$select->where("b.KONDISI_BARANG IN (".$params['KONDISI_BARANG_PENERIMAAN_FINAL'].")
					AND a.STATUS IN (".$params['STATUS_PENERIMAAN_FINAL'].")
					AND a.PENERIMAAN_DETIL_LINEN IN (".$params['PENERIMAAN_DETIL_LINEN'].")");
					unset($params['KONDISI_BARANG_PENERIMAAN_FINAL']);
					unset($params['STATUS_PENERIMAAN_FINAL']);
					unset($params['PENERIMAAN_DETIL_LINEN']);
				}
			}
			
			if(isset($params['KONDISI_BARANG_DISTRIBUSI']) && isset($params['DISTRIBUSI_DETIL_LINEN']) && isset($params['STATUS_DISTRIBUSI'])) {
				if(!System::isNull($params, 'KONDISI_BARANG_DISTRIBUSI', 'DISTRIBUSI_DETIL_LINEN', 'STATUS_DISTRIBUSI')) {
					$select->join(array('c' => new TableIdentifier("distribusi_no_seri_barang", "laundry")), "no_seri_barang_ruangan.ID = c.NO_SERI_BARANG_RUANGAN", array());
					$select->join(array('d' => new TableIdentifier("distribusi_detil_linen", "laundry")), "c.DISTRIBUSI_DETIL_LINEN = d.ID", array());
					$select->join(array('e' => new TableIdentifier("penerimaan_detil_linen", "laundry")), "d.PENERIMAAN_DETIL_LINEN = e.ID", array());
					$select->where("no_seri_barang_ruangan.KONDISI_BARANG IN (".$params['KONDISI_BARANG_DISTRIBUSI'].") 
					AND c.DISTRIBUSI_DETIL_LINEN IN (".$params['DISTRIBUSI_DETIL_LINEN'].")
					AND no_seri_barang_ruangan.STATUS IN (".$params['STATUS_DISTRIBUSI'].")");
					unset($params['KONDISI_BARANG_DISTRIBUSI']);
					unset($params['DISTRIBUSI_DETIL_LINEN']);
					unset($params['STATUS_DISTRIBUSI']);
				}
			}
			
			if(isset($params['KONDISI_BARANG_DISTRIBUSI_FINAL']) && isset($params['DISTRIBUSI_DETIL_LINEN']) && isset($params['STATUS_DISTRIBUSI_FINAL'])) {
				if(!System::isNull($params, 'KONDISI_BARANG_DISTRIBUSI_FINAL', 'DISTRIBUSI_DETIL_LINEN', 'STATUS_DISTRIBUSI_FINAL')) {
					$select->join(array('c' => new TableIdentifier("distribusi_no_seri_barang", "laundry")), "no_seri_barang_ruangan.ID = c.NO_SERI_BARANG_RUANGAN", array());
					$select->join(array('d' => new TableIdentifier("distribusi_detil_linen", "laundry")), "c.DISTRIBUSI_DETIL_LINEN = d.ID", array());
					$select->join(array('e' => new TableIdentifier("penerimaan_detil_linen", "laundry")), "d.PENERIMAAN_DETIL_LINEN = e.ID", array());
					$select->where("e.KONDISI_BARANG IN (".$params['KONDISI_BARANG_DISTRIBUSI_FINAL'].")
					AND c.DISTRIBUSI_DETIL_LINEN IN (".$params['DISTRIBUSI_DETIL_LINEN'].")
					AND c.STATUS IN (".$params['STATUS_DISTRIBUSI_FINAL'].")");
					unset($params['KONDISI_BARANG_DISTRIBUSI_FINAL']);
					unset($params['DISTRIBUSI_DETIL_LINEN']);
					unset($params['STATUS_DISTRIBUSI_FINAL']);
				}
			}
			
			$select->where($params);
			$select->order($orders);
		})->toArray();
	}
	
	public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;
		$this->entity->exchangeArray($data);
		//$cek = $this->table->select(array('BARANG_RUANGAN'=> $this->entity->get('BARANG_RUANGAN')));
		$cek = $this->table->select(array('BARANG_RUANGAN'=> $this->entity->get('BARANG_RUANGAN'), 'NO_SERI'=> $this->entity->get('NO_SERI')));
		if(count($cek) > 0){
			return array(
				'success' => false
			);
		} else {
			$id = is_numeric($this->entity->get('ID')) ? $this->entity->get('ID') : 0;
			if($id == 0) {
				$this->table->insert($this->entity->getArrayCopy());
				$id = $this->table->getLastInsertValue();
			} else {
				$this->table->update($this->entity->getArrayCopy(), array("ID" => $id));
			}			
			return array(
				'success' => true,
				'data' => $this->load(array('ID'=>$id))
			);			
		}
	}
	
	/* public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;
		$this->entity->exchangeArray($data);
		$id = $this->entity->get('ID') ? $this->entity->get('ID') : 0;
		if($id == 0) {
			$this->table->insert($this->entity->getArrayCopy());
		} else {
			$this->table->update($this->entity->getArrayCopy(), array("ID" => $id));
		}
		return array(
			'success' => true
		);
	} */
}