<?php
namespace MedicalRecord\V1\Rest\PemantuanHDIntradialitik;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use Pendaftaran\V1\Rest\Kunjungan\KunjunganService;

class Service extends DBService {
	
	private $kunjungan;
	protected $references = [
		"Kunjungan" => true
	];
	
	public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\PemantuanHDIntradialitik\\PemantuanHDIntradialitikEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("pemantuan_hd_intradialitik", "medicalrecord"));
		$this->entity = new PemantuanHDIntradialitikEntity();
		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
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

	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);

		foreach($data as &$entity) {
			$kunjungan = $this->kunjungan->load(['NOMOR' => $entity['KUNJUNGAN']]);
			if(count($kunjungan) > 0) $entity['REFERENSI']['KUNJUNGAN'] = $kunjungan[0];

			$results = $this->parseReferensi($entity, "pegawai");
			if(count($results) > 0) $entity["REFERENSI"]["OLEH"] = $results;
		}
		
		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'STATUS')) {
			$params['pemantuan_hd_intradialitik.STATUS'] = $params['STATUS'];
			unset($params['STATUS']);
		}

		if(!System::isNull($params, 'ID')) {
			$params['pemantuan_hd_intradialitik.ID'] = $params['ID'];
			unset($params['ID']);
		}
		
		$select->join(
			["pengguna" => new TableIdentifier('pengguna', 'aplikasi')],
			new \Laminas\Db\Sql\Predicate\Expression("pengguna.ID = pemantuan_hd_intradialitik.OLEH"),
			["NIP"],
			Select::JOIN_LEFT
		);

		$select->join(
			["pegawai" => new TableIdentifier('pegawai', 'master')],
			new \Laminas\Db\Sql\Predicate\Expression("pegawai.NIP = pengguna.NIP"),
			["pegawai_NAMA" => "NAMA", "pegawai_GELAR_DEPAN" => "GELAR_DEPAN", "pegawai_GELAR_BELAKANG" => "GELAR_BELAKANG"],
			Select::JOIN_LEFT
		);

		if(!System::isNull($params, 'HISTORY')) {
			unset($params['HISTORY']);
		
			$select->join(['k'=>new TableIdentifier('kunjungan', 'pendaftaran')], 'k.NOMOR = pemantuan_hd_intradialitik.KUNJUNGAN', []);
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