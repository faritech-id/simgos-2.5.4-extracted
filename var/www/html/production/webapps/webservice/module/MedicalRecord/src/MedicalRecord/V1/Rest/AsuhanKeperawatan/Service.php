<?php
namespace MedicalRecord\V1\Rest\AsuhanKeperawatan;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use Pendaftaran\V1\Rest\Kunjungan\KunjunganService;
use MedicalRecord\V1\Rest\IndikatorKeperawatan\Service as indikatorService;
use MedicalRecord\V1\Rest\DiagnosaKeperawatan\Service as diagnosaKeperawatanService;

class Service extends DBService {
	private $kunjungan;
	private $indikator;
	private $diagnosa;
	
	protected $references = [
		"Kunjungan" => true,
		"Indikator" => true,
		"Diagnosa" => true
    ];
	
	public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\AsuhanKeperawatan\\AsuhanKeperawatanEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("asuhan_keperawatan", "medicalrecord"));
		$this->entity = new AsuhanKeperawatanEntity();
		
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
			if($this->references['Indikator']) $this->indikator = new indikatorService(false);
			if($this->references['Diagnosa']) $this->diagnosa = new diagnosaKeperawatanService();
		}
	}
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);

		if($this->includeReferences) {
			foreach($data as &$entity) {
				$penver = $this->parseReferensi($entity, "penggunaver");
				if(count($penver) > 0) $entity["REFERENSI"]["PENGGUNA_VERIFIKASI"] = $penver;

				$results = $this->parseReferensi($entity, "pengguna");
				if(count($results) > 0) $entity["REFERENSI"]["PENGGUNA"] = $results;

				if($this->references['Kunjungan']) {
					$this->kunjungan->setReferences(json_decode(json_encode([						
						"Ruangan" => [
							"COLUMNS" => ['DESKRIPSI']
						]		
					])), true);
					$kunjungan = $this->kunjungan->load(['NOMOR' => $entity['KUNJUNGAN']]);
					if(count($kunjungan) > 0) $entity['REFERENSI']['KUNJUNGAN'] = $kunjungan[0];
				}

				if($this->references['Diagnosa']) {
					if($entity['DIAGNOSA'] != 0){
						$diagnosa = $this->diagnosa->load(['ID' => $entity['DIAGNOSA']]);
						if(count($diagnosa) > 0) $entity['REFERENSI']['DIAGNOSA'] = $diagnosa[0];
					}else{
						$entity['REFERENSI']['DIAGNOSA'] = [
							"DESKRIPSI" => $entity['DESK_DIAGNOSA']
						]; 
					}					
				}

				if($this->references['Indikator']) {
					$subjektif = $this->getDeskripsi($entity, "SUBJECKTIF", ['JENIS' => 1]);
					if(count($subjektif) > 0) $entity['REFERENSI']['SUBJEKTIF'] = $subjektif;

					$objektif = $this->getDeskripsi($entity, "OBJEKTIF", ['JENIS' => 2]);
					if(count($objektif) > 0) $entity['REFERENSI']['OBJEKTIF'] = $objektif;

					$subjektif_minor = $this->getDeskripsi($entity, "SUBJECT_MINOR", ['JENIS' => 1]);
					if(count($subjektif_minor) > 0) $entity['REFERENSI']['SUBJEKTIF_MINOR'] = $subjektif_minor;

					$objektif_minor = $this->getDeskripsi($entity, "OBJECT_MINOR", ['JENIS' => 2]);
					if(count($objektif_minor) > 0) $entity['REFERENSI']['OBJEKTIF_MINOR'] = $objektif_minor;

					$fr = $this->getDeskripsi($entity, "FAKTOR_RESIKO", ['JENIS' => 10]);
					if(count($fr) > 0) $entity['REFERENSI']['FAKTOR_RESIKO'] = $fr;

					$penyebap = $this->getDeskripsi($entity, "PENYEBAP", ['JENIS' => 3]);
					if(count($penyebap) > 0) $entity['REFERENSI']['PENYEBAP'] = $penyebap;

					$kriteriahasil = $this->getDeskripsi($entity, "KRITERIA_HASIL", ['JENIS' => 11]);
					if(count($kriteriahasil) > 0) $entity['REFERENSI']['KRITERIA_HASIL'] = $kriteriahasil;
					
					$obsrv = $this->getDeskripsi($entity, "OBSERVASI", ['JENIS' => 6]);
					if(count($obsrv) > 0) $entity['REFERENSI']['OBSERVASI'] = $obsrv;

					$theu = $this->getDeskripsi($entity, "THEURAPEUTIC", ['JENIS' => 7]);
					if(count($theu) > 0) $entity['REFERENSI']['THEURAPEUTIC'] = $theu;

					$edukasi = $this->getDeskripsi($entity, "EDUKASI", ['JENIS' => 8]);
					if(count($edukasi) > 0) $entity['REFERENSI']['EDUKASI'] = $edukasi;

					$kola = $this->getDeskripsi($entity, "KOLABORASI", ['JENIS' => 9]);
					if(count($kola) > 0) $entity['REFERENSI']['KOLABORASI'] = $kola;

					if($entity['TUJUAN'] != 0){
						$tujuan = $this->indikator->load(['JENIS' => 4, "ID" => $entity['TUJUAN']]);
						if(count($tujuan) > 0) $entity['REFERENSI']['TUJUAN'] = $tujuan[0];
					}else{
						$entity['REFERENSI']['TUJUAN'] = [
							"DESKRIPSI" => $entity['DESK_TUJUAN']
						]; 
					}	

					if($entity['INTERVENSI'] != 0){
						$inter = $this->indikator->load(['JENIS' => 5, "ID" => $entity['INTERVENSI']]);
						if(count($inter) > 0) $entity['REFERENSI']['INTERVENSI'] = $inter[0];
					}else{
						$entity['REFERENSI']['INTERVENSI'] = [
							"DESKRIPSI" => $entity['DESK_INTERVENSI']
						]; 
					}	
				}
			}
		}
		
		return $data; 
	}

	private function getDeskripsi($entity, $column, $params){
		$subjectif = json_decode($entity[$column]);
		$arrtemp = [];
		foreach($subjectif as $rec){
			$id = (int) $rec;
			if($id > 0){
				$params["ID"] = $id;
				$indikator = $this->indikator->load($params);
				array_push($arrtemp, $indikator[0]);
			}else {
				array_push($arrtemp, ["DESKRIPSI" => $rec]);	
			}							
		}
		return $arrtemp;
	}

	protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
		if(!$isCreated) {
			if(isset($data["STATUS"])) {
				if($data["STATUS"] == 2) {
					$entity["USER_VERIFIKASI"] = $data["OLEH"];
					unset($entity["OLEH"]);
				}
			}
		}
	}
	
	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'STATUS')) {
			$status = $params['STATUS'];
			$params['asuhan_keperawatan.STATUS'] = $status;
			unset($params['STATUS']);
		}

		if(!System::isNull($params, 'ID')) {
			$id = $params['ID'];
			$params['asuhan_keperawatan.ID'] = $id;
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
			['pengguna_GELAR_DEPAN' => 'GELAR_DEPAN', 'pengguna_NAMA' => 'NAMA', 'pengguna_GELAR_BELAKANG' => 'GELAR_BELAKANG', 'pengguna_NIP' => "NIP"],
			Select::JOIN_LEFT
		);

		$select->join(
			['u2' => new TableIdentifier('pengguna', 'aplikasi')],
			'u2.ID = USER_VERIFIKASI',
			[],
			Select::JOIN_LEFT
		);
		
		$select->join(
			['p2' => new TableIdentifier('pegawai', 'master')],
			'p2.NIP = u2.NIP',
			['penggunaver_GELAR_DEPAN' => 'GELAR_DEPAN', 'penggunaver_NAMA' => 'NAMA', 'penggunaver_GELAR_BELAKANG' => 'GELAR_BELAKANG', 'penggunaver_NIP' => "NIP"],
			Select::JOIN_LEFT
		);
		
		if(!System::isNull($params, 'HISTORY')) {
			unset($params['HISTORY']);
		
			$select->join(['k'=>new TableIdentifier('kunjungan', 'pendaftaran')], 'k.NOMOR = asuhan_keperawatan.KUNJUNGAN', []);
			$select->join(['p'=>new TableIdentifier('pendaftaran', 'pendaftaran')], 'p.NOMOR = k.NOPEN', []);
			// $select->where("k.FINAL_HASIL = 1");
			
			if(!System::isNull($params, 'NORM')) {
				$norm = $params['NORM'];
				$params['p.NORM'] = $norm;
				unset($params['NORM']); 
			}
		}
	}
}