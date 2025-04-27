<?php
namespace MedicalRecord\V1\Rest\PenilaianNyeri;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use General\V1\Rest\Referensi\ReferensiService;
use Aplikasi\V1\Rest\Pengguna\PenggunaService;
use Pendaftaran\V1\Rest\Kunjungan\KunjunganService;

class Service extends DBService {
	private $pengguna;
	private $referensi;
	private $kunjungan;

	protected $references = [
		"Kunjungan" => true
	];
	
	public function __construct($includeReferences = true, $references = array()) {
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\PenilaianNyeri\\PenilaianNyeriEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("penilaian_nyeri", "medicalrecord"));
		$this->entity = new PenilaianNyeriEntity();

		$this->referensi = new ReferensiService();
		$this->pengguna = new PenggunaService();

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

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'STATUS')) {
			$status = $params['STATUS'];
			$params['penilaian_nyeri.STATUS'] = $status;
			unset($params['STATUS']);
		}

		if(!System::isNull($params, 'ID')) {
			$id = $params['ID'];
			$params['penilaian_nyeri.ID'] = $id;
			unset($params['ID']);
		}
		
		if(!System::isNull($params, 'HISTORY')) {
			unset($params['HISTORY']);
		
			$select->join(array('k'=>new TableIdentifier('kunjungan', 'pendaftaran')), 'k.NOMOR = penilaian_nyeri.KUNJUNGAN', array());
			$select->join(array('p'=>new TableIdentifier('pendaftaran', 'pendaftaran')), 'p.NOMOR = k.NOPEN', array());
			
			if(!System::isNull($params, 'NORM')) {
				$norm = $params['NORM'];
				$params['p.NORM'] = $norm;
				unset($params['NORM']);
			}
		}
	}

	public function load($params = array(), $columns = array('*'), $edukasipasienkeluargas = array()) {
		$data = parent::load($params, $columns, $edukasipasienkeluargas);
		
		foreach($data as &$entity) {			
			$metode = $this->referensi->load(array('ID' => $entity['METODE'], 'JENIS'=>71));
			if(count($metode) > 0) $entity['REFERENSI']['METODE'] = $metode[0];

			if(!empty($entity['OLEH'])) {
				$pengguna = $this->pengguna->getPegawai($entity['OLEH']);
				if($pengguna) $entity['REFERENSI']['PETUGAS'] = $pengguna;
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
		}
		
		return $data;
	}
}