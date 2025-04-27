<?php
namespace MedicalRecord\V1\Rest\RiwayatPemberianObat;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use Pendaftaran\V1\Rest\Kunjungan\KunjunganService;
use Aplikasi\V1\Rest\Pengguna\PenggunaService;
use General\V1\Rest\FrekuensiAturanResep\FrekuensiAturanResepService;
use General\V1\Rest\Referensi\ReferensiService;

class Service extends DBService {	
	private $kunjungan;
	private $pengguna;
	private $frekuensiaturanresep;
	private $referensi;
	
	protected $references = [
		"Kunjungan" => true
	];
	
	public function __construct($includeReferences = true, $references = array()) {
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\RiwayatPemberianObat\\RiwayatPemberianObatEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("riwayat_pemberian_obat", "medicalrecord"));
		$this->entity = new RiwayatPemberianObatEntity();	
		$this->pengguna = new PenggunaService();	
		$this->frekuensiaturanresep = new FrekuensiAturanResepService();	
		$this->referensi = new ReferensiService();	
		
		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		if($includeReferences) {
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
				$results = $this->parseReferensi($entity, "pengguna");
				if(count($results) > 0) $entity["REFERENSI"]["PENGGUNA"] = $results;
				
				$frekuensiaturanresep = $this->frekuensiaturanresep->load(['ID' => $entity['FREKUENSI']]);
				if(count($frekuensiaturanresep) > 0) $entity['REFERENSI']['FREKUENSI_ATURAN_RESEP'] = $frekuensiaturanresep[0];
				
				$referensi = $this->referensi->load(['JENIS' => 217, 'ID' => $entity['RUTE']]);
				if(count($referensi) > 0) $entity['REFERENSI']['RUTE'] = $referensi[0];
			}
		}
		
		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'STATUS')) {
			$status = $params['STATUS'];
			$params['riwayat_pemberian_obat.STATUS'] = $status;
			unset($params['STATUS']);
		}
		
		if(isset($params['STATUS_REKONSILIASI_ADMISI'])) if(!System::isNull($params, 'STATUS_REKONSILIASI_ADMISI')){
			$select->where("(riwayat_pemberian_obat.STATUS IN (1, 2))");
			unset($params['STATUS_REKONSILIASI_ADMISI']);
		}

		if(!System::isNull($params, 'ID')) {
			$id = $params['ID'];
			$params['riwayat_pemberian_obat.ID'] = $id;
			unset($params['ID']);
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
		
			$select->join(['k'=>new TableIdentifier('kunjungan', 'pendaftaran')], 'k.NOMOR = riwayat_pemberian_obat.KUNJUNGAN', []);
			$select->join(['p'=>new TableIdentifier('pendaftaran', 'pendaftaran')], 'p.NOMOR = k.NOPEN', []);
			
			if(!System::isNull($params, 'NORM')) {
				$norm = $params['NORM'];
				$params['p.NORM'] = $norm;
				unset($params['NORM']);
			}
		}
	}
}