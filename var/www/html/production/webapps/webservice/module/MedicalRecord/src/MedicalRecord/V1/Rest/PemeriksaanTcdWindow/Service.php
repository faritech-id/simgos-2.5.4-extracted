<?php
namespace MedicalRecord\V1\Rest\PemeriksaanTcdWindow;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use DBService\generator\Generator;
use General\V1\Rest\Referensi\ReferensiService;
use Pendaftaran\V1\Rest\Kunjungan\KunjunganService;
use Aplikasi\V1\Rest\Pengguna\PenggunaService;

class Service extends DBService {
	private $referensi;
	private $kunjungan;
	private $pengguna;

	protected $references = [
		"Referensi" => true,
		"Kunjungan" => true
	];

	public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\PemeriksaanTcdWindow\\PemeriksaanTcdWindowEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("pemeriksaan_tcd_window", "medicalrecord"));
		$this->entity = new PemeriksaanTcdWindowEntity();

		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {
			if($this->references['Referensi']) $this->referensi = new ReferensiService();
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
				if($this->references['Referensi']) {
					$referensi = $this->referensi->load(['JENIS' => $entity['REFERENSI_JENIS'], 'ID' => $entity['REFERENSI_ID']]);
					if(count($referensi) > 0) $entity['REFERENSI']['REFERENSI_ID'] = $referensi[0];
				}
				if($this->references['Kunjungan']) {
					$this->kunjungan->setReferences(json_decode(json_encode([						
						"Ruangan" => [
							"COLUMNS" => ['DESKRIPSI']
						]		
					])), true);
					$kunjungan = $this->kunjungan->load(['NOMOR' => $entity['KUNJUNGAN']]);
					if(count($kunjungan) > 0) $entity['REFERENSI']['KUNJUNGAN'] = $kunjungan[0];
				}
				$results = $this->parseReferensi($entity, "pengguna");
				if(count($results) > 0) $entity["REFERENSI"]["PENGGUNA"] = $results;
			}	
		}

		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'STATUS')) {
			$status = $params['STATUS'];
			$params['pemeriksaan_tcd_window.STATUS'] = $status;
			unset($params['STATUS']);
		}
		
		if(!System::isNull($params, 'ID')) {
			$id = $params['ID'];
			$params['pemeriksaan_tcd_window.ID'] = $id;
			unset($params['ID']);
		}

		if(!System::isNull($params, 'TAHUN')) {
			$tahun = $params['TAHUN'];
			$select->where("(YEAR(pemeriksaan_tcd_window.DIBUAT_TANGGAL) = '".$tahun."')");
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
		
			$select->join(['k'=>new TableIdentifier('kunjungan', 'pendaftaran')], 'k.NOMOR = pemeriksaan_tcd_window.KUNJUNGAN', []);
			$select->join(['p'=>new TableIdentifier('pendaftaran', 'pendaftaran')], 'p.NOMOR = k.NOPEN', []);
			$select->where("k.FINAL_HASIL = 1");
			
			if(!System::isNull($params, 'NORM')) {
				$norm = $params['NORM'];
				$params['p.NORM'] = $norm;
				unset($params['NORM']);
			}
		}
	}
}