<?php
namespace Layanan\V1\Rest\PasienMeninggal;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;
use Laminas\Db\Sql\Select;
use DBService\System;
use Pendaftaran\V1\Rest\Kunjungan\KunjunganService;
use Pendaftaran\V1\Rest\Pendaftaran\PendaftaranService;

use General\V1\Rest\Dokter\DokterService;

class PasienMeninggalService extends Service
{
	private $dokter;
	private $kunjungan;
	private $pendaftaran;
	
	protected $references = [
		"Kunjungan" => true,
		"Pendaftaran" => true,
	];
	
    public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "Layanan\\V1\\Rest\\PasienMeninggal\\PasienMeninggalEntity";	
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("pasien_meninggal", "layanan"));
		$this->entity = new PasienMeninggalEntity();
		$this->dokter = new DokterService();
		$this->setReferences($references);
		$this->includeReferences = $includeReferences;
		if($includeReferences) {
			if($this->references['Kunjungan']) {
				$this->kunjungan = new KunjunganService(true, [
					'Pendaftaran' => false,
				]);
			}
			if($this->references['Pendaftaran']) {
				$this->pendaftaran = new PendaftaranService(true, [
					'PasienMeninggal' => false,
					'PasienPulang' => false
				]);
			}
		}
    }
        
	public function load($params = array(), $columns = array('*'), $orders = array()) {
		$data = parent::load($params, $columns, $orders);
		
		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['Kunjungan']) {
					if(is_object($this->references['Kunjungan'])) {
						$this->kunjungan->includeReferences = true;
						$references = isset($this->references['Kunjungan']->REFERENSI) ? (array) $this->references['Kunjungan']->REFERENSI : [];
						$this->kunjungan->setReferences($references, true);
						if(isset($this->references['Kunjungan']->COLUMNS)) $this->kunjungan->setColumns((array) $this->references['Kunjungan']->COLUMNS);						
					}

					$kunjungan = $this->kunjungan->load(['kunjungan.NOMOR' => $entity['KUNJUNGAN']]);
					if(count($kunjungan) > 0) $entity['REFERENSI']['KUNJUNGAN'] = $kunjungan[0];
				
					if($this->references['Pendaftaran']){
						if(is_object($this->references['Pendaftaran'])) {
							$this->pendaftaran->includeReferences = true;
							$references = isset($this->references['Pendaftaran']->REFERENSI) ? (array) $this->references['Pendaftaran']->REFERENSI : [];
							$this->pendaftaran->setReferences($references, true);
							if(isset($this->references['Pendaftaran']->COLUMNS)) $this->pendaftaran->setColumns((array) $this->references['Pendaftaran']->COLUMNS);						
						}
						if(count($kunjungan) > 0){
							$pendaftaran = $this->pendaftaran->load(['NOMOR' => $kunjungan[0]["NOPEN"]]);
							if(count($pendaftaran) > 0) $entity['REFERENSI']['PENDAFTARAN'] = $pendaftaran[0];
						}						
					}
				}

				$dokter = $this->dokter->load(array('ID' => $entity['DOKTER']));
				if(count($dokter) > 0) $entity['REFERENSI']['DOKTER'] = $dokter[0];
			}	
		}
		
		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {		
		$select->join(
			array('kjgn' => new TableIdentifier('kunjungan', 'pendaftaran')),
			'kjgn.NOMOR = KUNJUNGAN',
			array()
		);

		$select->join(
			['pp' => new TableIdentifier('pasien_pulang', 'layanan')],
			'pp.KUNJUNGAN = pasien_meninggal.KUNJUNGAN',
			[]
		);

		if(!System::isNull($params, 'ID')) {			
			$params["pasien_meninggal.ID"] = $params["ID"];
			unset($params["ID"]);
		}

		if(!System::isNull($params, 'NOPEN')) {			
			$params["kjgn.NOPEN"] = $params["NOPEN"];
			unset($params["NOPEN"]);
		}

		if(!System::isNull($params, 'KUNJUNGAN')) {			
			$params["pasien_meninggal.KUNJUNGAN"] = $params["KUNJUNGAN"];
			unset($params["KUNJUNGAN"]);
		}

		if(!System::isNull($params, 'KEADAAN_KELUAR')) {			
			$params["pp.KEADAAN"] = $params["KEADAAN_KELUAR"];
			unset($params["KEADAAN_KELUAR"]);
		}

		if(!System::isNull($params, 'RUANGAN')) {			
			$params["kjgn.RUANGAN"] = $params["RUANGAN"];
			unset($params["KEADAAN_KELUAR"]);
		}

		if(!System::isNull($params, 'STATUS')) {			
			$params["pasien_meninggal.STATUS"] = $params["STATUS"];
			unset($params["STATUS"]);
		}
		
		if(!System::isNull($params, 'TANGGAL')) {			
			$select->where->between("pasien_meninggal.TANGGAL", $params["TANGGAL"]." 00:00:00", $params["TANGGAL"]." 23:59:59");
			unset($params["TANGGAL"]);
		}

		if(!System::isNull($params, 'TANGGAL_AWAL') && !System::isNull($params, 'TANGGAL_AKHIR')) {			
			$select->where->between("pasien_meninggal.TANGGAL", $params["TANGGAL_AWAL"]." 00:00:00", $params["TANGGAL_AKHIR"]." 23:59:59");
			unset($params["TANGGAL_AWAL"]);
			unset($params["TANGGAL_AKHIR"]);
		}

		if(!System::isNull($params, 'SPESIALIS')) {	
			$select->join(
				['dokter' => new TableIdentifier('dokter', 'master')],
				'dokter.ID = pasien_meninggal.DOKTER',
				[]
			);
			$select->join(
				['pegawai' => new TableIdentifier('pegawai', 'master')],
				'pegawai.NIP = dokter.NIP',
				[]
			);
			$param["pegawai.SMF"] = $params["SPESIALIS"];
			unset($params["SPESIALIS"]);
		}
	}
}