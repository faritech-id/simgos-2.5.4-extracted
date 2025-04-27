<?php
namespace MedicalRecord\V1\Rest\DischargePlanningFaktorRisiko;

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
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\DischargePlanningFaktorRisiko\\DischargePlanningFaktorRisikoEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("discharge_planning_faktor_risiko", "medicalrecord"));
		$this->entity = new DischargePlanningFaktorRisikoEntity();
		$this->pengguna = new PenggunaService();

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
				'Mutasi' => false
			]);
		}
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'STATUS')) {
			$status = $params['STATUS'];
			$params['discharge_planning_faktor_risiko.STATUS'] = $status;
			unset($params['STATUS']);
		}
		
		if(!System::isNull($params, 'ID')) {
			$id = $params['ID'];
			$params['discharge_planning_faktor_risiko.ID'] = $id;
			unset($params['ID']);
		}
		
		if(isset($params['QUERY'])) {
			if(!System::isNull($params, 'QUERY')) {
				$select->join(array('kj'=>new TableIdentifier('kunjungan', 'pendaftaran')), 'kj.NOMOR = discharge_planning_faktor_risiko.KUNJUNGAN', array());
				$select->join(array('pd'=>new TableIdentifier('pendaftaran', 'pendaftaran')), 'pd.NOMOR = kj.NOPEN', array());
				$select->where("(pd.NORM LIKE '%".$params['QUERY']."%')");
				
				unset($params['QUERY']);
			}
		}

		$select->join(
			['u' => new TableIdentifier('pengguna', 'aplikasi')],
			'u.ID = USER',
			[],
			Select::JOIN_LEFT
		);
		
		$select->join(
			['pg' => new TableIdentifier('pengguna', 'aplikasi')],
			'pg.ID = USER_REASSESSMENT',
			[],
			Select::JOIN_LEFT
		);
		
		$select->join(
			['p' => new TableIdentifier('pegawai', 'master')],
			'p.NIP = u.NIP',
			['pengguna_GELAR_DEPAN' => 'GELAR_DEPAN', 'pengguna_NAMA' => 'NAMA', 'pengguna_GELAR_BELAKANG' => 'GELAR_BELAKANG'],
			Select::JOIN_LEFT
		);

		if(!System::isNull($params, 'HISTORY')) {
			unset($params['HISTORY']);
		
			$select->join(array('k'=>new TableIdentifier('kunjungan', 'pendaftaran')), 'k.NOMOR = discharge_planning_faktor_risiko.KUNJUNGAN', array());
			$select->join(array('p'=>new TableIdentifier('pendaftaran', 'pendaftaran')), 'p.NOMOR = k.NOPEN', array());
			
			if(!System::isNull($params, 'NORM')) {
				$norm = $params['NORM'];
				$params['p.NORM'] = $norm;
				unset($params['NORM']);
			}
		}
	}

	public function load($params = array(), $columns = array('*'), $dischargeplanningfaktorrisikos = array()) {
		$data = parent::load($params, $columns, $dischargeplanningfaktorrisikos);
		
		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['Kunjungan']) {
					$this->kunjungan->setReferences(json_decode(json_encode([						
						"Ruangan" => [
							"COLUMNS" => ['DESKRIPSI']
						],		
						/* "Pendaftaran" => [
							"COLUMNS" => $this->references['Pendaftaran']->COLUMNS
						]		 */
						"Pendaftaran" => [
							"REFERENSI" => [
								"Penjamin" => true,
								"Pasien" => true
							]
						]
					])), true);
					$kunjungan = $this->kunjungan->load(['NOMOR' => $entity['KUNJUNGAN']]);
					if(count($kunjungan) > 0) $entity['REFERENSI']['KUNJUNGAN'] = $kunjungan[0];
				}
				$results = $this->parseReferensi($entity, "pengguna");
				if(count($results) > 0) $entity["REFERENSI"]["PENGGUNA"] = $results;
			}
		}
		
		return $data;
	}
}