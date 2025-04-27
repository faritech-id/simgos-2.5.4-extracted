<?php
namespace MedicalRecord\V1\Rest\PemeriksaanEkg;

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
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\PemeriksaanEkg\\PemeriksaanEkgEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("pemeriksaan_ekg", "medicalrecord"));
		$this->entity = new PemeriksaanEkgEntity();

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
				$results = $this->parseReferensi($entity, "pengguna");
				if(count($results) > 0) $entity["REFERENSI"]["PENGGUNA"] = $results;

				$Irama = $this->referensi->load(array('ID' => $entity['IRAMA'], 'JENIS'=>224));
				if(count($Irama) > 0) $entity['REFERENSI']['IRAMA'] = $Irama[0];	

				$gelp = $this->referensi->load(array('ID' => $entity['GEL_P'], 'JENIS'=>225));
				if(count($gelp) > 0) $entity['REFERENSI']['GEL_P'] = $gelp[0];	

				$qrskompleks = $this->referensi->load(array('ID' => $entity['QRS_KOMPLEKS'], 'JENIS'=>226));
				if(count($qrskompleks) > 0) $entity['REFERENSI']['QRS_KOMPLEKS'] = $qrskompleks[0];
				
				$regulasi = $this->referensi->load(array('ID' => $entity['REGULARITAS'], 'JENIS'=>227));
				if(count($regulasi) > 0) $entity['REFERENSI']['REGULARITAS'] = $regulasi[0];

				$printerval = $this->referensi->load(array('ID' => $entity['PR_INTERVAL'], 'JENIS'=>228));
				if(count($printerval) > 0) $entity['REFERENSI']['PR_INTERVAL'] = $printerval[0];

				$stsegment = $this->referensi->load(array('ID' => $entity['ST_SEGMEN'], 'JENIS'=>229));
				if(count($stsegment) > 0) $entity['REFERENSI']['ST_SEGMEN'] = $stsegment[0];

				$axix = $this->referensi->load(array('ID' => $entity['AXIX'], 'JENIS'=>230));
				if(count($axix) > 0) $entity['REFERENSI']['AXIX'] = $axix[0];

				$gelt = $this->referensi->load(array('ID' => $entity['GEL_T'], 'JENIS'=>231));
				if(count($axix) > 0) $entity['REFERENSI']['GEL_T'] = $gelt[0];

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
			$params['pemeriksaan_ekg.STATUS'] = $status;
			unset($params['STATUS']);
		}

		if(!System::isNull($params, 'ID')) {
			$id = $params['ID'];
			$params['pemeriksaan_ekg.ID'] = $id;
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
		
			$select->join(['k'=>new TableIdentifier('kunjungan', 'pendaftaran')], 'k.NOMOR = pemeriksaan_ekg.KUNJUNGAN', []);
			$select->join(['p'=>new TableIdentifier('pendaftaran', 'pendaftaran')], 'p.NOMOR = k.NOPEN', []);
			
			if(!System::isNull($params, 'NORM')) {
				$norm = $params['NORM'];
				$params['p.NORM'] = $norm;
				unset($params['NORM']);
			}
		}	
	}
}