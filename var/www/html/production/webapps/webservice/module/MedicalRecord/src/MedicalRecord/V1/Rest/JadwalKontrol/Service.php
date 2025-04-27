<?php
namespace MedicalRecord\V1\Rest\JadwalKontrol;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use DBService\generator\Generator;
use Laminas\Db\Sql\Expression;
use Pendaftaran\V1\Rest\Kunjungan\KunjunganService;
use General\V1\Rest\Dokter\DokterService;
use General\V1\Rest\Referensi\ReferensiService;
use PenjaminRS\V1\Rest\Dpjp\Service as PenjaminRSService;
use General\V1\Rest\Ruangan\RuanganService;
use General\V1\Rest\PenjaminRuangan\PenjaminRuanganService;

class Service extends DBService {
	private $ruangan;
	private $kunjungan;
	private $tujuan;
	private $dokter;
	private $dpjppejaminrs;
	private $PenjaminRuangan;
	
	protected $references = array(
		"Kunjungan" => true,
		"Tujuan" => true,
		"Dokter" => true,
		"Ruangan" => true,
		"DPJPPenjaminRs" => true,
		"PenjaminRuangan" => true
	);

	public function __construct($includeReferences = true, $references = array()) {
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\JadwalKontrol\\JadwalKontrolEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("jadwal_kontrol", "medicalrecord"));
		$this->entity = new JadwalKontrolEntity();

		$this->setReferences($references);
		
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
				'Mutasi' => false,
				'DPJPPenjaminRs' => true,
			]);
			if($this->references['Ruangan']) $this->ruangan = new RuanganService();
			if($this->references['Tujuan']) $this->tujuan = new ReferensiService();
			if($this->references['Dokter']) $this->dokter = new DokterService();
			if($this->references['DPJPPenjaminRs']) $this->dpjppejaminrs = new PenjaminRSService();
			if($this->references['PenjaminRuangan']) $this->PenjaminRuangan = new PenjaminRuanganService();
		}
	}

	protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
		if($isCreated) $entity->set("NOMOR", Generator::generateNoKontrol());
	}

	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);

		if($this->includeReferences) {
			foreach($data as &$entity) {
				/*if($this->references['TenagaMedis']) {
					$tenagaMedis = $this->tenagaMedis->load(['ID' => $entity['TENAGA_MEDIS'], "JENIS" => $entity["JENIS"]]);
					if(count($tenagaMedis) > 0) $entity['REFERENSI']['TENAGA_MEDIS'] = $tenagaMedis[0];
				}*/
				if($this->references['Kunjungan']) {
					$this->kunjungan->setReferences(json_decode(json_encode([						
						"Ruangan" => [
							"COLUMNS" => ['DESKRIPSI']
						],
						"Pendaftaran" => [
							"REFERENSI" => [
								"Penjamin" => true,
								"Pasien" => true
							]
						],
						'DPJPPenjaminRs' => true,
					])), true);
					$kunjungan = $this->kunjungan->load(['NOMOR' => $entity['KUNJUNGAN']]);
					if(count($kunjungan) > 0) $entity['REFERENSI']['KUNJUNGAN'] = $kunjungan[0];
				}
				if($this->references['Ruangan']) {
					$ruangan = $this->ruangan->load(['ID' => $entity['RUANGAN']]);
					if(count($ruangan) > 0) $entity['REFERENSI']['RUANGAN'] = $ruangan[0];
				}
				if($this->references['Tujuan']) {
					$tujuan = $this->tujuan->load(array('JENIS' => 26, 'ID' => $entity['TUJUAN']));
					if(count($tujuan) > 0) $entity['REFERENSI']['TUJUAN'] = $tujuan[0];
				}
				if($this->references['Dokter']) {
					$dokter = $this->dokter->load(array('ID' => $entity['DOKTER']));
					if(count($dokter) > 0) $entity['REFERENSI']['DOKTER'] = $dokter[0];
				}
				if($this->references['DPJPPenjaminRs']) {
					$dpjppejaminrs = $this->dpjppejaminrs->load(array('DPJP_RS' => $entity['DOKTER']));
					if(count($dpjppejaminrs) > 0) $entity['REFERENSI']['DPJP_PENJAMIN_RS'] = $dpjppejaminrs[0];
				}
				if($this->references['PenjaminRuangan']) {
					$PenjaminRuangan = $this->PenjaminRuangan->load(['RUANGAN_RS' => $entity['RUANGAN'], 'PENJAMIN' => 2]);
					if(count($PenjaminRuangan) > 0) $entity['REFERENSI']['PENJAMIN_RUANGAN'] = $PenjaminRuangan[0];
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
			$params["k.FINAL_HASIL"] = 1;
			
			if(!System::isNull($params, 'NORM')) {
				$norm = $params['NORM'];
				$params['p.NORM'] = $norm;
				unset($params['NORM']);
			}

			if(!System::isNull($params, 'NOPEN')) {
				$nopen = $params['NOPEN'];
				$params['p.NOMOR'] = $nopen;
				unset($params['NOPEN']);
			}

			if(!System::isNull($params, 'TANGGAL_NOREF')) {
				$usr = $this->user;
				$select->join(
					['par' => new TableIdentifier('pengguna_akses_ruangan', 'aplikasi')],
					'par.RUANGAN = k.RUANGAN',
					[]
				);
				$params['par.STATUS'] = 1;
				$params['par.PENGGUNA'] = $usr;
				$params['jadwal_kontrol.TANGGAL'] = $params['TANGGAL_NOREF'];

				if(isset($params["k.FINAL_HASIL"])) unset($params["k.FINAL_HASIL"]);
				unset($params['TANGGAL_NOREF']);
			}
			if(!System::isNull($params, 'TANGGAL_BUAT')) {
				$usr = $this->user;
				$select->join(
					['par' => new TableIdentifier('pengguna_akses_ruangan', 'aplikasi')],
					'par.RUANGAN = k.RUANGAN',
					[]
				);
				$params['par.STATUS'] = 1;
				$params['par.PENGGUNA'] = $usr;

				$awal = $params['TANGGAL_BUAT']." 00:00:00";
				$akhir = $params['TANGGAL_BUAT']." 23:59:59";
				$select->where->between("jadwal_kontrol.DIBUAT_TANGGAL", $awal, $akhir);
				
				if(isset($params["k.FINAL_HASIL"])) unset($params["k.FINAL_HASIL"]);
				unset($params['TANGGAL_BUAT']);
			}
		}
	}
}