<?php
namespace MedicalRecord\V1\Rest\DischargePlanningSkrining;

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
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\DischargePlanningSkrining\\DischargePlanningSkriningEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("discharge_planning_skrining", "medicalrecord"));
		$this->entity = new DischargePlanningSkriningEntity();
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
			$params['discharge_planning_skrining.STATUS'] = $status;
			unset($params['STATUS']);
		}
		
		if(!System::isNull($params, 'ID')) {
			$id = $params['ID'];
			$params['discharge_planning_skrining.ID'] = $id;
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
		
			$select->join(array('k'=>new TableIdentifier('kunjungan', 'pendaftaran')), 'k.NOMOR = discharge_planning_skrining.KUNJUNGAN', array());
			$select->join(array('p'=>new TableIdentifier('pendaftaran', 'pendaftaran')), 'p.NOMOR = k.NOPEN', array());
			
			if(!System::isNull($params, 'NORM')) {
				$norm = $params['NORM'];
				$params['p.NORM'] = $norm;
				unset($params['NORM']);
			}
		}
	}

	public function load($params = array(), $columns = array('*'), $dischargeplanningskrinings = array()) {
		$data = parent::load($params, $columns, $dischargeplanningskrinings);
		$kebutuhan = [
			'KPB_RAWAT_LUKA' => 'Rawat Luka'
			, 'KPB_HIV' => 'HIV AIDS'
			, 'KPB_TB' => 'TB'
			, 'KPB_DM' => 'DM'
			, 'KPB_DM_TERAPI_INSULIN' => 'DM dengan terapi insulin'
			, 'KPB_STROKE' => 'Stroke'
			, 'KPB_PPOK' => 'PPOK'
			, 'KPB_CKD' => 'CKD'
			, 'KPB_PASIEN_KEMO' => 'Pasien Kemoterapi'
		];

		$penggunaan = [
			'PAM_KATETER_URIN' => 'Kateter Urin'
			, 'PAM_NGT' => 'NGT'
			, 'PAM_TRAECHOSTOMY' => 'Traechostomy'
			, 'PAM_COLOSTOMY' => 'Colostomy'
			, 'PAM_LAINNYA' => ''
		];
		
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

				$desk = "";
				foreach($kebutuhan as $key => $value){
					if($entity[$key] == 1) $desk = empty($desk) ? $value : $desk .'|'. $value;
				}

				if($entity["KEBUTUHAN_PELAYANAN_BERKELANJUTAN_KPB"] == 1) $entity['REFERENSI']['KEBUTUHAN_PELAYANAN_BERKELANJUTAN_KPB'] = 'Ya ('.$desk.')';
				else $entity['REFERENSI']['KEBUTUHAN_PELAYANAN_BERKELANJUTAN_KPB'] = 'Tidak';

				$desk = "";
				foreach($penggunaan as $key => $value){
					if($entity[$key] == 1) $desk = empty($desk) ? $value : $desk .'|'. $value;
					elseif($value == "") $desk = empty($desk) ? $entity[$key] : !empty($entity[$key]) ? $desk .'|'. $entity[$key] : $desk;
				}

				if($entity["PENGGUNAAN_ALAT_MEDIS_PAM"] == 1) $entity['REFERENSI']['PENGGUNAAN_ALAT_MEDIS_PAM'] = 'Ya ('.$desk.')';
				else $entity['REFERENSI']['PENGGUNAAN_ALAT_MEDIS_PAM'] = 'Tidak';
			}
		}
		
		return $data;
	}
}