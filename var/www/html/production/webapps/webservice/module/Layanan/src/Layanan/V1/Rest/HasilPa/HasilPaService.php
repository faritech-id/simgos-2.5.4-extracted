<?php
namespace Layanan\V1\Rest\HasilPa;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;
use Laminas\Db\Sql\Select;
use Laminas\Db\Sql\Expression;
use DBService\System;

use General\V1\Rest\Dokter\DokterService;
use General\V1\Rest\Referensi\ReferensiService;
use Pendaftaran\V1\Rest\Kunjungan\KunjunganService;
use Layanan\V1\Rest\TindakanMedis\TindakanMedisService;

class HasilPaService extends Service
{
	private $dokter;
	private $referensi;
	private $Kunjungan;
	private $TindakanMedis;
	
    public function __construct() {
		$this->config["entityName"] = "Layanan\\V1\\Rest\\HasilPa\\HasilPaEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("hasil_pa", "layanan"));
		$this->entity = new HasilPaEntity();
		
		$this->dokter = new DokterService();
		$this->referensi = new ReferensiService();
		$this->Kunjungan = new KunjunganService();
		$this->TindakanMedis = new TindakanMedisService();
    }

	protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
		if($isCreated) {
			if(!isset($data["TANGGAL"])) $entity->set('TANGGAL', new \Laminas\Db\Sql\Expression('NOW()'));
		}
	}

	public function findByKunjunganDanJenisPemeriksaan($kjgn, $jenis) {
		$finds = $this->load(["KUNJUNGAN" => $kjgn, 'JENIS_PEMERIKSAAN' => $jenis]);
		if(count($finds) > 0) return $finds[0];
		return null;
	}
        
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		foreach($data as &$entity) {
			$dokter = $this->dokter->load(['ID' => $entity['DOKTER']]);
			if(count($dokter) > 0) $entity['REFERENSI']['DOKTER'] = $dokter[0];
			
			$referensi = $this->referensi->load(['JENIS' => $entity['JENIS_PEMERIKSAAN'], 'ID' => 66]);
			if(count($referensi) > 0) $entity['REFERENSI']['JENIS_PEMERIKSAAN'] = $referensi[0];

			$Kunjungan = $this->Kunjungan->load(array('NOMOR' => $entity['KUNJUNGAN']));
			if(count($Kunjungan) > 0) $entity['REFERENSI']['KUNJUNGAN'] = $Kunjungan[0];
			
			$TindakanMedis = $this->TindakanMedis->load(array('KUNJUNGAN' => $entity['KUNJUNGAN']));
			if(count($TindakanMedis) > 0) $entity['REFERENSI']['TINDAKAN_MEDIS'] = $TindakanMedis[0];
		}
		
		return $data;
	}

	
	public function getDataBerkasKlaimObatPa($data){
		$adapter = $this->table->getAdapter();
		
		if (isset($data->TINDAKAN_DESKRIPSI)) {
			$strLmt = $adapter->query("SELECT hp.*, td.NAMA
				FROM pendaftaran.pendaftaran a
				, pendaftaran.kunjungan k
				, layanan.tindakan_medis tm
				, master.ruangan r
				, layanan.hasil_pa hp
				, master.tindakan td
				WHERE a.NOMOR = k.NOPEN 
				AND k.NOMOR = tm.KUNJUNGAN 
				AND k.RUANGAN = r.ID 
				AND tm.KUNJUNGAN = hp.KUNJUNGAN
				AND NORM=?
				AND DATE(a.TANGGAL) <= ?
				AND r.JENIS_KUNJUNGAN=4 
				AND r.JENIS= 5 
				AND r.`STATUS` = 1 
				AND tm.TINDAKAN=td.ID
				AND td.NAMA LIKE '".$data->TINDAKAN_DESKRIPSI."%'
				GROUP BY hp.KUNJUNGAN
				-- AND INSTR(r.DESKRIPSI,'Patologi Anatomi') > 0
			");
			
			$results = $strLmt->execute([$data->NORM,$data->TANGGAL]);
		}
		else {
			$strLmt = $adapter->query("SELECT hp.*
				FROM pendaftaran.pendaftaran a
				, pendaftaran.kunjungan k
				, layanan.tindakan_medis tm
				, master.ruangan r
				, layanan.hasil_pa hp
				WHERE a.NOMOR = k.NOPEN 
				AND k.NOMOR = tm.KUNJUNGAN 
				AND k.RUANGAN = r.ID 
				AND tm.KUNJUNGAN = hp.KUNJUNGAN
				AND NORM=? 
				AND DATE(a.TANGGAL) <= ? 
				AND r.JENIS_KUNJUNGAN=4 
				AND r.JENIS= 5 
				AND r.`STATUS` = 1 
				GROUP BY hp.KUNJUNGAN
				-- AND INSTR(r.DESKRIPSI,'Patologi Anatomi') > 0
			");
			
			$results = $strLmt->execute([$data->NORM,$data->TANGGAL]);
		}
		
		$data = array();
		if(count($results) > 0){
			foreach($results as $row) {				
				$dokters = $this->dokter->load(['ID' => $row['DOKTER']]);
				if(count($dokters) > 0) $row['REFERENSI']['DOKTER'] = $dokters[0];
				
				$referensi = $this->referensi->load(array('ID' => $row['JENIS_PEMERIKSAAN'], 'JENIS'=>66));
				if(count($referensi) > 0) $row['REFERENSI']['JENIS_PEMERIKSAAN'] = $referensi[0];
				
				$Kunjungans = $this->Kunjungan->load(array('NOMOR' => $row['KUNJUNGAN']));
				if(count($Kunjungans) > 0) $row['REFERENSI']['KUNJUNGAN'] = $Kunjungans[0];
				
				$TindakanMediss = $this->TindakanMedis->load(array('KUNJUNGAN' => $row['KUNJUNGAN']));
				if(count($TindakanMediss) > 0) $row['REFERENSI']['TINDAKAN_MEDIS'] = $TindakanMediss[0];
				
				$data[] = $row;
			}
			return $data;
		} else {
			return $data;
		}
	}
}