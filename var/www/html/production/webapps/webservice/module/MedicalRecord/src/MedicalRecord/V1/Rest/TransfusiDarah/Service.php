<?php
namespace MedicalRecord\V1\Rest\TransfusiDarah;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use DBService\generator\Generator;
use General\V1\Rest\Referensi\ReferensiService;
use Pendaftaran\V1\Rest\Kunjungan\KunjunganService;
use Aplikasi\V1\Rest\Pengguna\PenggunaService;
use MedicalRecord\V1\Rest\TransfusiDarahDetail\Service  as TransfusiDarahDetailService;


class Service extends DBService {
	private $referensi;
	private $kunjungan;
	private $pengguna;
	private $transfusidarahdetail;

	protected $references = [
		"Referensi" => true,
		"Kunjungan" => true
	];

	public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\TransfusiDarah\\TransfusiDarahEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("pemeriksaan_transfusi_darah", "medicalrecord"));
		$this->entity = new TransfusiDarahEntity();
		$this->pengguna = new PenggunaService();
		$this->transfusidarahdetail = new TransfusiDarahDetailService();

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

	protected function onAfterSaveCallback($id, $data) {
		$this->SimpanDetil($data, $id);
	}
	
	private function SimpanDetil($data, $id) {
		if(isset($data['TRANSFUSI_DARAH_DETAIL'])) {
			foreach($data['TRANSFUSI_DARAH_DETAIL'] as $dtl) {
				$dtl['TRANSFUSI_DARAH'] = $id;
				$this->transfusidarahdetail->simpanData($dtl, true);
			}
		}
	}

	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		
		if($this->includeReferences) {
			foreach($data as &$entity) {
				$results = $this->parseReferensi($entity, "pengguna");
				if(count($results) > 0) $entity["REFERENSI"]["PENGGUNA"] = $results;

				$jenisDarah = $this->referensi->load(['ID' => $entity['JENIS_DARAH'], 'JENIS'=>213]);
				if(count($jenisDarah) > 0) $entity['REFERENSI']['JENIS_DARAH'] = $jenisDarah[0];
				
				$jenisDarah = $this->referensi->load(['ID' => $entity['GOLOGAN_DARAH'], 'JENIS'=>6]);
				if(count($jenisDarah) > 0) $entity['REFERENSI']['GOLOGAN_DARAH'] = $jenisDarah[0];	
				
				
				$result = $this->transfusidarahdetail->load(['TRANSFUSI_DARAH' => $entity['ID']]);
				if(count($result) > 0) $entity['REFERENSI']['TRANSFUSI_DARAH_DETAIL'] = $result;
	
				if($this->references['Kunjungan']) {
					$this->kunjungan->setReferences(json_decode(json_encode([						
						"Ruangan" => [
							"COLUMNS" => ['DESKRIPSI']
						]		
					])), true);
					$kunjungan = $this->kunjungan->load(['NOMOR' => $entity['KUNJUNGAN']]);
					if(count($kunjungan) > 0) $entity['REFERENSI']['KUNJUNGAN'] = $kunjungan[0];
				}
			}	
		}

		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'STATUS')) {
			$status = $params['STATUS'];
			$params['pemeriksaan_transfusi_darah.STATUS'] = $status;
			unset($params['STATUS']);
		}

		if(!System::isNull($params, 'ID')) {
			$id = $params['ID'];
			$params['pemeriksaan_transfusi_darah.ID'] = $id;
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
		
			$select->join(['k'=>new TableIdentifier('kunjungan', 'pendaftaran')], 'k.NOMOR = pemeriksaan_transfusi_darah.KUNJUNGAN', []);
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