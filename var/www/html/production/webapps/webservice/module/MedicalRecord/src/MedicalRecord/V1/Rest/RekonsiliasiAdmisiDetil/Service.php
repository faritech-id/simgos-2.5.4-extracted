<?php
namespace MedicalRecord\V1\Rest\RekonsiliasiAdmisiDetil;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;

use General\V1\Rest\Referensi\ReferensiService;
use General\V1\Rest\FrekuensiAturanResep\FrekuensiAturanResepService;
use Layanan\V1\Rest\Farmasi\FarmasiService;
use Inventory\V1\Rest\Barang\BarangService;
use MedicalRecord\V1\Rest\RiwayatPemberianObat\Service as RiwayatPemberianObatService;

class Service extends DBService
{
	private $Referensi;
	private $FrekuensiAturanResep;
	private $PerubahanAturanPakai;
	private $Farmasi;
	private $Barang;
	private $RiwayatPemberianObat;
	
    public function __construct() {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("rekonsiliasi_admisi_detil", "medicalrecord"));
		$this->entity = new RekonsiliasiAdmisiDetilEntity();
		
		$this->Referensi = new ReferensiService();
		$this->FrekuensiAturanResep = new FrekuensiAturanResepService();
		$this->PerubahanAturanPakai = new FrekuensiAturanResepService();
		$this->Farmasi = new FarmasiService();
		$this->Barang = new BarangService();
		$this->RiwayatPemberianObat = new RiwayatPemberianObatService();
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
			
			$RiwayatPemberianObat = $this->RiwayatPemberianObat->load(array('ID' => $entity['RIWAYAT_PEMBERIAN_OBAT']));
			if(count($RiwayatPemberianObat) > 0) $entity['REFERENSI']['RIWAYAT_PEMBERIAN_OBAT'] = $RiwayatPemberianObat[0];
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
				$select->where("(rekonsiliasi_admisi_detil.STATUS IN (1, 2))");
				unset($params['STATUS']);
			}
			
			$select->where($params);
			
			$select->order($orders);
		})->toArray();
	}
	
	public function getDataRekonsiliasiAdmisiDetil($data){
		$adapter = $this->table->getAdapter();
		$strLmt = $adapter->query("SELECT a.ID IDREKONSILIASIADMISIDETIL, a.OBAT_DARI_LUAR, ib.NAMA NAMA_OBAT_DARI_LUAR, a.DOSIS, a.FREKUENSI, far.FREKUENSI DESKRIPSI_FREKUENSI, a.RUTE, ref.DESKRIPSI DESKRIPSI_RUTE
									, a.TINDAK_LANJUT, ref2.DESKRIPSI DESKRIPSI_TINDAK_LANJUT, a.PERUBAHAN_ATURAN_PAKAI, pak.FREKUENSI DESKRIPSI_PERUBAHAN_ATURAN_PAKAI
									FROM medicalrecord.rekonsiliasi_admisi_detil a
									JOIN medicalrecord.rekonsiliasi_admisi b ON a.REKONSILIASI_ADMISI=b.ID
									JOIN pendaftaran.kunjungan c ON c.NOMOR=b.KUNJUNGAN
									-- JOIN `master`.ruangan ru on ru.ID = c.RUANGAN
									JOIN pendaftaran.pendaftaran d ON d.NOMOR=c.NOPEN
									LEFT JOIN master.referensi ref ON a.RUTE=ref.ID AND ref.JENIS=217
									LEFT JOIN master.referensi ref2 ON a.TINDAK_LANJUT=ref2.ID AND ref2.JENIS=245
									LEFT JOIN master.frekuensi_aturan_resep far ON far.ID=a.FREKUENSI
									LEFT JOIN master.frekuensi_aturan_resep pak ON pak.ID=a.PERUBAHAN_ATURAN_PAKAI
									LEFT JOIN inventory.barang ib ON ib.ID=a.OBAT_DARI_LUAR
									WHERE d.NORM=? AND b.STATUS=2 AND c.NOMOR=(SELECT c1.NOMOR 
											FROM medicalrecord.rekonsiliasi_admisi b1 
											JOIN pendaftaran.kunjungan c1 ON c1.NOMOR=b1.KUNJUNGAN
											-- JOIN `master`.ruangan ru on ru.ID = c1.RUANGAN
											JOIN pendaftaran.pendaftaran d1 ON d1.NOMOR=c1.NOPEN
											WHERE d1.NORM=d.NORM AND b1.STATUS=2
											-- AND ru.JENIS_KUNJUNGAN = 2
											GROUP BY c1.NOMOR
											ORDER BY c1.MASUK DESC
											LIMIT 1)
											-- AND ru.JENIS_KUNJUNGAN = 2
											");
		
		$results = $strLmt->execute(array($data->NORM));
		$data = array();
		if(count($results) > 0){
			foreach($results as $row) {
				$data[] = $row;
			}
			return $data;
		} else {
			return $data;
		}
	}
}
