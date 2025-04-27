<?php
namespace MedicalRecord\V1\Rest\StatusFungsional;

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
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\StatusFungsional\\StatusFungsionalEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("status_fungsional", "medicalrecord"));
		$this->entity = new StatusFungsionalEntity();
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
			$params['status_fungsional.STATUS'] = $status;
			unset($params['STATUS']);
		}

		if(!System::isNull($params, 'ID')) {
			$id = $params['ID'];
			$params['status_fungsional.ID'] = $id;
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
		
			$select->join(array('k'=>new TableIdentifier('kunjungan', 'pendaftaran')), 'k.NOMOR = status_fungsional.KUNJUNGAN', array());
			$select->join(array('p'=>new TableIdentifier('pendaftaran', 'pendaftaran')), 'p.NOMOR = k.NOPEN', array());
			
			if(!System::isNull($params, 'NORM')) {
				$norm = $params['NORM'];
				$params['p.NORM'] = $norm;
				unset($params['NORM']);
			}
		}		
	}	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);

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
			if($entity['CACAT_TUBUH_TIDAK'] == 1) $cacattubuh = 'Tidak';
			else $cacattubuh = 'Ya |'.$entity['KET_CACAT_TUBUH'];
			$entity['REFERENSI']['CACATTUBUH'] = $cacattubuh;
			
			if($entity['TONGKAT'] == 1) $alat1 = 'Tongkat|';
			else $alat1 = '';
			if($entity['KURSI_RODA'] == 1) $alat2 = 'Kursi Roda|';
			else $alat2 = '';
			if($entity['BRANKARD'] == 1) $alat3 = 'Brankard|';
			else $alat3 = '';
			if($entity['WALKER'] == 1) $alat4 = 'Walker|';
			else $alat4 = '';
			$alat5 = $entity['ALAT_BANTU'];
			
			if($entity['TANPA_ALAT_BANTU'] == 1) $entity['REFERENSI']['ALATBANTU'] = 'Tidak Ada';
			else $entity['REFERENSI']['ALATBANTU'] = 'Ya ('.$alat1.$alat2.$alat3.$alat4.$alat5.')';			
		}
		return $data;
	}
}