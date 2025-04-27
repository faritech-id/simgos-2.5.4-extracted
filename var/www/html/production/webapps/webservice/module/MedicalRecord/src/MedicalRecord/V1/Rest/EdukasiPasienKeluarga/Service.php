<?php
namespace MedicalRecord\V1\Rest\EdukasiPasienKeluarga;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use Pendaftaran\V1\Rest\Kunjungan\KunjunganService;
use Aplikasi\V1\Rest\Pengguna\PenggunaService;

class Service extends DBService {	
	private $kunjungan;
	private $pengguna;
	
	protected $references = [
		"Kunjungan" => true
	];

	public function __construct($includeReferences = true, $references = array()) {
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\EdukasiPasienKeluarga\\EdukasiPasienKeluargaEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("edukasi_pasien_keluarga", "medicalrecord"));
		$this->entity = new EdukasiPasienKeluargaEntity();
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
			$params['edukasi_pasien_keluarga.STATUS'] = $status;
			unset($params['STATUS']);
		}
		
		if(!System::isNull($params, 'ID')) {
			$id = $params['ID'];
			$params['edukasi_pasien_keluarga.ID'] = $id;
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
		
			$select->join(array('k'=>new TableIdentifier('kunjungan', 'pendaftaran')), 'k.NOMOR = edukasi_pasien_keluarga.KUNJUNGAN', array());
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
			}
		}

		foreach($data as &$entity) {
			if($entity['KESEDIAAN'] == 1)$entity['REFERENSI']['KESEDIAAN'] = 'Ya';
			else $entity['REFERENSI']['KESEDIAAN'] = 'Tidak';
			
			if($entity['HAMBATAN_PENDENGARAN'] == 1) $hambatan1 = 'Pendengaran|';
			else $hambatan1 = '';
			if($entity['HAMBATAN_PENGLIHATAN'] == 1) $hambatan2 = 'Penglihatan|';
			else $hambatan2 = '';
			if($entity['HAMBATAN_KOGNITIF'] == 1) $hambatan3 = 'Kognitif|';
			else $hambatan3 = '';
			if($entity['HAMBATAN_FISIK'] == 1) $hambatan4 = 'Fisik|';
			else $hambatan4 = '';
			if($entity['HAMBATAN_BUDAYA'] == 1) $hambatan5 = 'Budaya|';
			else $hambatan5 = '';
			if($entity['HAMBATAN_EMOSI'] == 1) $hambatan6 = 'Emosi|';
			else $hambatan6 = '';
			if($entity['HAMBATAN_BAHASA'] == 1) $hambatan7 = 'Bahasa|';
			else $hambatan7 = '';
			$hambatan8 = $entity['HAMBATAN_LAINNYA'];
			
			if($entity['HAMBATAN'] == 1) $entity['REFERENSI']['HAMBATAN'] = 'Ya ('.$hambatan1.$hambatan2.$hambatan3.$hambatan4.$hambatan5.$hambatan6.$hambatan7.$hambatan8.'|)';
			else $entity['REFERENSI']['HAMBATAN'] = 'Tidak';
			
			if($entity['PENERJEMAH'] == 1) $entity['REFERENSI']['PENERJEMAH'] = 'Ya ('.$entity['BAHASA'].')';
			else $entity['REFERENSI']['PENERJEMAH'] = 'Tidak';

			$arredukasi = [
				'EDUKASI_DIAGNOSA' => 'Kondisi kesehatan dan diagnosa pasti dan penatalaksanaannya'
				, 'EDUKASI_PENYAKIT' => ''
				, 'EDUKASI_REHAB_MEDIK' => 'Teknik rehabilitasi'
				, 'EDUKASI_HKP' => 'Hak & Kewajiban Pasien'
				, 'EDUKASI_OBAT' => 'Penggunaan obat secara efektif dan efek samping interaksinya'
				, 'EDUKASI_NYERI' => 'Manajemen Nyeri'
				, 'EDUKASI_NUTRISI' => 'Diet & Nutrisi'
				, 'EDUKASI_PENGGUNAAN_ALAT' => 'Penggunaan alat medis yang aman'
				, 'EDUKASI_HAK_BERPARTISIPASI' => 'Hak untuk berpartisipasi pada pelayanan'
				, 'EDUKASI_PROSEDURE_PENUNJANG' => 'Prosedur pemeriksaan penunjang'
				, 'EDUKASI_PEMBERIAN_INFORMED_CONSENT' => 'Proses pemberian informed consent'
				, 'EDUKASI_PENUNDAAN_PELAYANAN' => 'Penundaan pelayanan'
				, 'EDUKASI_KELAMBATAN_PELAYANAN' => 'Kelambatan pelayanan'
				, 'EDUKASI_CUCI_TANGAN' => 'Cuci tangan dengan benar'
				, 'EDUKASI_BAHAYA_MEROKO' => 'Bahaya meroko'
				, 'EDUKASI_RUJUKAN_PASIEN' => 'Edukasi rujukan pasien'
				, 'EDUKASI_PERENCANAAN_PULANG' => 'Edukasi perencanaan pulang'
			];

			$desk = "";
			foreach($arredukasi as $key => $value){
				if($entity[$key] == 1) $desk = empty($desk) ? $value : $desk .'|'. $value;
				elseif($value == "") $desk = empty($desk) ? $entity[$key] : !empty($entity[$key]) ? $desk .'|'. $entity[$key] : $desk;
			}
			
			if($entity['STATUS_LAIN'] == 1) $desk = $desk. '| Lain-lain ( '.$entity['DESKRIPSI_LAINYA'].' )';

			$entity['REFERENSI']['EDUKASI'] = $desk;
		}
		
		return $data;
	}
}