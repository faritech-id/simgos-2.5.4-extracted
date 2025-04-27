<?php
namespace MedicalRecord\V1\Rest\RekonsiliasiDischargeDetil;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;

use General\V1\Rest\Referensi\ReferensiService;
use General\V1\Rest\FrekuensiAturanResep\FrekuensiAturanResepService;
use Layanan\V1\Rest\Farmasi\FarmasiService;
use Inventory\V1\Rest\Barang\BarangService;
use MedicalRecord\V1\Rest\RekonsiliasiAdmisiDetil\Service as RekonsiliasiAdmisiDetilService;
use MedicalRecord\V1\Rest\RekonsiliasiTransferDetil\Service as RekonsiliasiTransferDetilService;

class Service extends DBService
{
	private $Referensi;
	private $FrekuensiAturanResep;
	private $PerubahanAturanPakai;
	private $Farmasi;
	private $Barang;
	private $RekonsiliasiAdmisiDetil;
	private $RekonsiliasiTransferDetil;
	
    public function __construct() {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("rekonsiliasi_discharge_detil", "medicalrecord"));
		$this->entity = new RekonsiliasiDischargeDetilEntity();
		
		$this->Referensi = new ReferensiService();
		$this->FrekuensiAturanResep = new FrekuensiAturanResepService();
		$this->PerubahanAturanPakai = new FrekuensiAturanResepService();
		$this->Farmasi = new FarmasiService();
		$this->Barang = new BarangService();
		$this->RekonsiliasiAdmisiDetil = new RekonsiliasiAdmisiDetilService();
		$this->RekonsiliasiTransferDetil = new RekonsiliasiTransferDetilService();
    }
	
	public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;
		$this->entity->exchangeArray($data);
		$id = is_numeric($this->entity->get('ID')) ? $this->entity->get('ID') : 0;
		if($id == 0) {
			$this->table->insert($this->entity->getArrayCopy());
			$id = $this->table->getLastInsertValue();
		} else {
			$this->table->update($this->entity->getArrayCopy(), array("ID" => $id));
		}
		
		return array(
			'success' => true
		);
	}
	
	public function load($params = array(), $columns = array('*'), $penjualans = array()) {
		$data = parent::load($params, $columns, $penjualans);
		
		foreach($data as &$entity) {
			$FrekuensiAturanResep = $this->FrekuensiAturanResep->load(array('ID' => $entity['FREKUENSI']));
			if(count($FrekuensiAturanResep) > 0) $entity['REFERENSI']['FREKUENSI'] = $FrekuensiAturanResep[0];
			
			$Referensi = $this->Referensi->load(array('JENIS' => 217, 'ID' => $entity['RUTE']));
			if(count($Referensi) > 0) $entity['REFERENSI']['RUTE'] = $Referensi[0];
			
			$Referensi = $this->Referensi->load(array('JENIS' => 245, 'ID' => $entity['TINDAK_LANJUT']));
			if(count($Referensi) > 0) $entity['REFERENSI']['TINDAK_LANJUT'] = $Referensi[0];
			
			$PerubahanAturanPakai = $this->PerubahanAturanPakai->load(array('ID' => $entity['PERUBAHAN_ATURAN_PAKAI']));
			if(count($PerubahanAturanPakai) > 0) $entity['REFERENSI']['PERUBAHAN_ATURAN_PAKAI'] = $PerubahanAturanPakai[0];
			
			/* $Referensi = $this->Referensi->load(array('JENIS' => 41, 'ID' => $entity['PERUBAHAN_ATURAN_PAKAI']));
			if(count($Referensi) > 0) $entity['REFERENSI']['PERUBAHAN_ATURAN_PAKAI'] = $Referensi[0]; */
			
			$Referensi = $this->Referensi->load(array('JENIS' => 244, 'ID' => $entity['JENIS_REKONSILIASI']));
			if(count($Referensi) > 0) $entity['REFERENSI']['JENIS_REKONSILIASI'] = $Referensi[0];
			
			$Farmasi = $this->Farmasi->load(array('ID' => $entity['LAYANAN_FARMASI']));
			if(count($Farmasi) > 0) $entity['REFERENSI']['LAYANAN_FARMASI'] = $Farmasi[0];
			
			$Barang = $this->Barang->load(array('ID' => $entity['OBAT_DARI_LUAR']));
			if(count($Barang) > 0) $entity['REFERENSI']['OBAT'] = $Barang[0];
			
			$RekonsiliasiAdmisiDetil = $this->RekonsiliasiAdmisiDetil->load(array('ID' => $entity['REKONSILIASI_ADMISI_DETIL']));
			if(count($RekonsiliasiAdmisiDetil) > 0) $entity['REFERENSI']['REKONSILIASI_ADMISI_DETIL'] = $RekonsiliasiAdmisiDetil[0];
			
			$RekonsiliasiTransferDetil = $this->RekonsiliasiTransferDetil->load(array('ID' => $entity['REKONSILIASI_TRANSFER_DETIL']));
			if(count($RekonsiliasiTransferDetil) > 0) $entity['REFERENSI']['REKONSILIASI_TRANSFER_DETIL'] = $RekonsiliasiTransferDetil[0];
		}
		
		return $data;
	}
	
	protected function query($columns, $params, $isCount = false, $orders = array()) {		
		$params = is_array($params) ? $params : (array) $params;		

		return $this->table->select(function(Select $select) use ($isCount, $params, $columns, $orders) {
			if($isCount) $select->columns(array('rows' => new \Laminas\Db\Sql\Expression('COUNT(1)')));
			else if(!$isCount) $select->columns($columns);			
			/* if(!System::isNull($params, 'start') && !System::isNull($params, 'limit')) {	
				if(!$isCount) $select->offset((int) $params['start'])->limit((int) $params['limit']);
				unset($params['start']);
				unset($params['limit']);
				
			} else $select->offset(0)->limit($this->limit); */
			
			if(isset($params['STATUS'])) if(!System::isNull($params, 'STATUS')){
				$select->where("(rekonsiliasi_discharge_detil.STATUS IN (1, 2))");
				unset($params['STATUS']);
			}
			
			$select->where($params);
			
			$select->order($orders);
		})->toArray();
	}
	
	public function getDataRekonsiliasiDischargeDetil($data){
		
	}
}
