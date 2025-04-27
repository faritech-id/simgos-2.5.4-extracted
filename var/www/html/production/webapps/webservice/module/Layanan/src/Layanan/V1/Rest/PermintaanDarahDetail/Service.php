<?php
namespace Layanan\V1\Rest\PermintaanDarahDetail;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use DBService\generator\Generator;
use General\V1\Rest\Referensi\ReferensiService;
use General\V1\Rest\Ruangan\RuanganService;
use General\V1\Rest\Dokter\DokterService;
use General\V1\Rest\Pegawai\PegawaiService;
use Pendaftaran\V1\Rest\Kunjungan\KunjunganService;
use Aplikasi\V1\Rest\Pengguna\PenggunaService;

class Service extends DBService {
	private $ruangan;
	private $referensi;
	private $detilrad;
	private $dokter;
	private $kunjungan;

	private $pengguna;
	private $pegawai;
	
	protected $references = [
		'Ruangan' => true,
		'Referensi' => true,
		'Dokter' => true,
		'OrderDetil' => true,
		'Kunjungan' => true
	];

	public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "Layanan\\V1\\Rest\\PermintaanDarahDetail\\PermintaanDarahDetailEntity";
		$this->config["entityId"] = "NOMOR";
		$this->config["autoIncrement"] = false;
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("permintaan_darah_detail", "layanan"));
		$this->entity = new PermintaanDarahDetailEntity();

		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {
			if($this->references['Ruangan']) $this->ruangan = new RuanganService();
			if($this->references['Referensi']) $this->referensi = new ReferensiService();
			if($this->references['Dokter']) $this->dokter = new DokterService();
			if($this->references['Kunjungan']) $this->kunjungan = new KunjunganService();
		}
		$this->pengguna = new PenggunaService();
		$this->pegawai = new PegawaiService();
	}

	protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
			if($isCreated) {
			$kunjungan = $this->kunjungan->load(['kunjungan.NOMOR' => $entity->get('KUNJUNGAN')]);
			if(count($kunjungan) > 0) {
			Generator::reinitialize();
				$nomor = Generator::generateNoOrderPermintaanDarah($kunjungan[0]['RUANGAN']);
			$this->entity->set('NOMOR', $nomor);
			}
		}
	}
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		
		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['Kunjungan']) {
					if(is_object($this->references['Kunjungan'])) {
						$references = isset($this->references['Kunjungan']->REFERENSI) ? (array) $this->references['Kunjungan']->REFERENSI : [];
						$this->kunjungan->setReferences($references, true);
						if(isset($this->references['Kunjungan']->COLUMNS)) $this->kunjungan->setColumns((array) $this->references['Kunjungan']->COLUMNS);
					}
					$kunjungan = $this->kunjungan->load(['kunjungan.NOMOR' => $entity['KUNJUNGAN']]);
					if(count($kunjungan) > 0) $entity['REFERENSI']['KUNJUNGAN'] = $kunjungan[0];
				}
				
				if($this->references['Referensi']) {
					$referensi = $this->referensi->load(['JENIS' => 255,'ID' => $entity['KOMPONEN']]);
					if(count($referensi) > 0) $entity['REFERENSI']['KOMPONEN'] = $referensi[0];
				}

				if(!empty($entity['OLEH'])) {
					$pengguna = $this->pengguna->getPegawai($entity['OLEH']);
					if($pengguna) $entity['REFERENSI']['PETUGAS'] = $pengguna;
				}
			}
		}
		
		return $data;
	}
}