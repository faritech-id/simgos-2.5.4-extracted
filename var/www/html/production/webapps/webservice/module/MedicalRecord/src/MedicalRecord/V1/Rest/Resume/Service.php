<?php
namespace MedicalRecord\V1\Rest\Resume;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use DBService\generator\Generator;
/* use Pendaftaran\V1\Rest\Kunjungan\KunjunganService;
use General\V1\Rest\Dokter\DokterService;
use General\V1\Rest\Referensi\ReferensiService; */

class Service extends DBService {
	/* private $kunjungan;
	private $tujuan;
	private $dokter;
	
	protected $references = array(
		"Kunjungan" => true,
		"Tujuan" => true,
		"Dokter" => true
	); */

	public function __construct($includeReferences = true /* $references = array() */) {
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\Resume\\ResumeEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("resume", "medicalrecord"));
		$this->entity = new ResumeEntity();

		/* $this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {
			if($this->references['Kunjungan']) $this->kunjungan = new KunjunganService(true, [
				'Ruangan' => true,
				'Referensi' => false,
				'Pendaftaran' => true,
				'RuangKamarTidur' => false,
				'PasienPulang' => false,
				'Pembatalan' => false,
				'Perujuk' => false,
				'Mutasi' => false
			]);
			if($this->references['Tujuan']) $this->tujuan = new ReferensiService();
			if($this->references['Dokter']) $this->dokter = new DokterService(); 
		} */
	}

	/* protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
		if($isCreated) $entity->set("NOMOR", Generator::generateNoKontrol());
	}

	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);

		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['Kunjungan']) {
					$this->kunjungan->setReferences(json_decode(json_encode([						
						"Ruangan" => [
							"COLUMNS" => ['DESKRIPSI']
						],
						"Pendaftaran" => [
							"REFERENSI" => [
								"Penjamin" => true
							]
						]		
					])), true);
					$kunjungan = $this->kunjungan->load(['NOMOR' => $entity['KUNJUNGAN']]);
					if(count($kunjungan) > 0) $entity['REFERENSI']['KUNJUNGAN'] = $kunjungan[0];
				}
				if($this->references['Tujuan']) {
					$tujuan = $this->tujuan->load(array('JENIS' => 26, 'ID' => $entity['TUJUAN']));
					if(count($tujuan) > 0) $entity['REFERENSI']['TUJUAN'] = $tujuan[0];
				}
				if($this->references['Dokter']) {
					$dokter = $this->dokter->load(array('ID' => $entity['DOKTER']));
					if(count($dokter) > 0) $entity['REFERENSI']['DOKTER'] = $dokter[0];
				}
			}
		}
		
		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'STATUS')) {
			$status = $params['STATUS'];
			$params['jadwal_kontrol.STATUS'] = $status;
			unset($params['STATUS']);
		}
		
		if(!System::isNull($params, 'TAHUN')) {
			$tahun = $params['TAHUN'];
			$select->where("(YEAR(jadwal_kontrol.DIBUAT_TANGGAL) = '".$tahun."')");
			unset($params['TAHUN']);
		}

		if(!System::isNull($params, 'HISTORY')) {
			unset($params['HISTORY']);
		
			$select->join(['k'=>new TableIdentifier('kunjungan', 'pendaftaran')], 'k.NOMOR = jadwal_kontrol.KUNJUNGAN', []);
			$select->join(['p'=>new TableIdentifier('pendaftaran', 'pendaftaran')], 'p.NOMOR = k.NOPEN', []);
			$select->where("k.FINAL_HASIL = 1");
			
			if(!System::isNull($params, 'NORM')) {
				$norm = $params['NORM'];
				$params['p.NORM'] = $norm;
				unset($params['NORM']);
			}
		}
	} */
}