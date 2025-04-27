<?php
namespace MedicalRecord\V1\Rest\PerencanaanRawatInap;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use DBService\generator\Generator;
use General\V1\Rest\Referensi\ReferensiService;
use Pendaftaran\V1\Rest\Kunjungan\KunjunganService;
use General\V1\Rest\Dokter\DokterService;

class Service extends DBService {
	private $kunjungan;
	private $referensi;
	
	protected $references = array(
		"Kunjungan" => true,
		"Dokter" => true,
	);

	public function __construct($includeReferences = true, $references = array()) {
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\PerencanaanRawatInap\\PerencanaanRawatInapEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("perencanaan_rawat_inap", "medicalrecord"));
		$this->entity = new PerencanaanRawatInapEntity();
		$this->referensi = new ReferensiService();

		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {
			if($this->references['Dokter']) $this->dokter = new DokterService();
			if($this->references['Kunjungan']) $this->kunjungan = new KunjunganService(true, [
				'Ruangan' => true,
				'Referensi' => false,
				'RuangKamarTidur' => false,
				'PasienPulang' => false,
				'Pembatalan' => false,
				'Perujuk' => false,
				'Mutasi' => false,
			]);
		}
	}

	protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
		if($isCreated) $entity->set("NOMOR", Generator::generateNoSPRI());
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
								"Penjamin" => true,
								"DiagnosaMasuk" => true,
								"Pasien" => true
							]
						],
						'DPJPPenjaminRs' => true
					])), true);
					$kunjungan = $this->kunjungan->load(['NOMOR' => $entity['KUNJUNGAN']]);
					if(count($kunjungan) > 0) $entity['REFERENSI']['KUNJUNGAN'] = $kunjungan[0];
				}
				
			$result = $this->referensi->load(['JENIS' => 242, 'ID' => $entity['JENIS_RUANG_PERAWATAN']]);
			if(count($result) > 0) $entity['REFERENSI']['JENIS_RUANG_PERAWATAN'] = $result[0];

			$result = $this->referensi->load(['JENIS' => 243, 'ID' => $entity['JENIS_PERAWATAN']]);
			if(count($result) > 0) $entity['REFERENSI']['JENIS_PERAWATAN'] = $result[0];

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
			$params['perencanaan_rawat_inap.STATUS'] = $status;
			unset($params['STATUS']);
		}
		
		if(!System::isNull($params, 'TAHUN')) {
			$tahun = $params['TAHUN'];
			$select->where("(YEAR(perencanaan_rawat_inap.TANGGAL) = '".$tahun."')");
			unset($params['TAHUN']);
		}

		if(!System::isNull($params, 'HISTORY')) {
			unset($params['HISTORY']);
		
			$select->join(['k'=>new TableIdentifier('kunjungan', 'pendaftaran')], 'k.NOMOR = perencanaan_rawat_inap.KUNJUNGAN', []);
			$select->join(['p'=>new TableIdentifier('pendaftaran', 'pendaftaran')], 'p.NOMOR = k.NOPEN', []);
			$params['k.FINAL_HASIL'] = 1;
			
			if(!System::isNull($params, 'NORM')) {
				$norm = $params['NORM'];
				$params['p.NORM'] = $norm;
				unset($params['NORM']);
			}

			if(!System::isNull($params, 'TANGGAL_MONITORING')) {
				$tanggalnoref = $params['TANGGAL_MONITORING'];
				$usr = $this->user;
				$select->join(
					['par' => new TableIdentifier('pengguna_akses_ruangan', 'aplikasi')],
					'par.RUANGAN = k.RUANGAN',
					[]
				);

				$params['par.STATUS'] = 1;
				$params['par.PENGGUNA'] = $usr;
				$params['perencanaan_rawat_inap.TANGGAL'] = $params['TANGGAL_MONITORING'];
				
				if(isset($params["k.FINAL_HASIL"])) unset($params["k.FINAL_HASIL"]);

				unset($params['TANGGAL_MONITORING']);
			}
		}
	}
}