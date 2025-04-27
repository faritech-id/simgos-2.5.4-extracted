<?php
namespace MedicalRecord\V1\Rest\SuratKelahiran;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use General\V1\Rest\Dokter\DokterService;
use General\V1\Rest\Perawat\PerawatService;
use Pendaftaran\V1\Rest\Kunjungan\KunjunganService;
use General\V1\Rest\KeluargaPasien\KeluargaPasienService;
use General\V1\Rest\KartuIdentitasKeluarga\Service as KartuIdentitasKeluargaService;

class Service extends DBService {
	private $kunjungan;
	private $dokter;
	private $perawat;
	private $KeluargaPasien;
	
	protected $references = [
		"Kunjungan" => true,
		"Dokter" => true,
		"Perawat" => true,
		"KeluargaPasien" => true
	];

	public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\SuratKelahiran\\SuratKelahiranEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("surat_kelahiran", "medicalrecord"));
		$this->entity = new SuratKelahiranEntity();
		
		$this->setReferences($references);		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {
			if($this->references['KeluargaPasien']) $this->KeluargaPasien = new KeluargaPasienService();
			if($this->references['Dokter']) $this->dokter = new DokterService();
			if($this->references['Perawat']) $this->perawat = new PerawatService();
			if($this->references['Kunjungan']) $this->kunjungan = new KunjunganService(true, [
				'Ruangan' => true,
				'Referensi' => false,
				'Pendaftaran' => false,
				'RuangKamarTidur' => false,
				'PasienPulang' => false,
				'Pembatalan' => false,
				'Perujuk' => false,
				'Mutasi' => false
			]);
		}
	}

	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['Kunjungan']) {
					$this->kunjungan->setReferences(json_decode(json_encode([						
						"Ruangan" => [
							"COLUMNS" => ['DESKRIPSI']
						]		
					])), true);
					$kunjungan = $this->kunjungan->load(['NOMOR' => $entity['KUNJUNGAN']]);
					if(count($kunjungan) > 0) $entity['REFERENSI']['KUNJUNGAN'] = $kunjungan[0];
				}

				if($this->references['KeluargaPasien']){
					$KeluargaPasien = $this->KeluargaPasien->load(['ID' => $entity['BAPAK']]);
					if(count($KeluargaPasien) > 0) $entity['REFERENSI']['BAPAK'] = $KeluargaPasien[0];

					$KeluargaPasien = $this->KeluargaPasien->load(['ID' => $entity['IBU']]);
					if(count($KeluargaPasien) > 0) $entity['REFERENSI']['IBU'] = $KeluargaPasien[0];
				}	

				if($this->references['Dokter']){
					$dokter = $this->dokter->load(['ID' => $entity['DPJP']]);
					if(count($dokter) > 0) $entity['REFERENSI']['DPJP'] = $dokter[0];
				}

				if($this->references['Perawat']){
					$perawat = $this->perawat->load(['ID' => $entity['BIDAN']]);
					if(count($perawat) > 0) $entity['REFERENSI']['BIDAN'] = $perawat[0];
				}

				$results = $this->parseReferensi($entity, "pengguna");
				if(count($results) > 0) $entity["REFERENSI"]["PENGGUNA"] = $results;
			}	
		}
		
		return $data;
	}
	protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
		if($isCreated) $entity->set("NOMOR", $this->generateNomor());
	}
	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		
		if(!System::isNull($params, 'STATUS')) {
			$status = $params['STATUS'];
			$params['surat_kelahiran.STATUS'] = $status;
			unset($params['STATUS']);
		}

		if(!System::isNull($params, 'ID')) {
			$id = $params['ID'];
			$params['surat_kelahiran.ID'] = $id;
			unset($params['ID']);
		}
		
		if(!System::isNull($params, 'TAHUN')) {
			$tahun = $params['TAHUN'];
			$select->where("(YEAR(surat_kelahiran.DIBUAT_TANGGAL) = '".$tahun."')");
			unset($params['TAHUN']);
		}

		$select->join(
			['u' => new TableIdentifier('pengguna', 'aplikasi')],
			'u.ID = OLEH',
			[]
		);
		

		$select->join(
			['p' => new TableIdentifier('pegawai', 'master')],
			'p.NIP = u.NIP',
			['pengguna_GELAR_DEPAN' => 'GELAR_DEPAN', 'pengguna_NAMA' => 'NAMA', 'pengguna_GELAR_BELAKANG' => 'GELAR_BELAKANG'],
			Select::JOIN_LEFT
		);

		if(!System::isNull($params, 'HISTORY')) {
			unset($params['HISTORY']);
		
			$select->join(['k'=>new TableIdentifier('kunjungan', 'pendaftaran')], 'k.NOMOR = surat_kelahiran.KUNJUNGAN', []);
			$select->join(['p'=>new TableIdentifier('pendaftaran', 'pendaftaran')], 'p.NOMOR = k.NOPEN', []);
			$select->where("k.FINAL_HASIL = 1");
			
			if(!System::isNull($params, 'NORM')) {
				$norm = $params['NORM'];
				$params['p.NORM'] = $norm;
				unset($params['NORM']);
			}
		}
	}
	public function generateNomor() {
        $adapter = $this->table->getAdapter();
		$conn = $adapter->getDriver()->getConnection();
	    $result = $conn->execute("SELECT generator.generateNoSuratKelahiran(YEAR(NOW())) NOMOR");
        $data = $result->current();
        return $data["NOMOR"];
    }
	
}