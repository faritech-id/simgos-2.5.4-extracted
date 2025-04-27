<?php
namespace Pendaftaran\V1\Rest\PengantarPasien;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use Zend\json\Json;
use DBService\System;
use DBService\Service as DBService;
use Pendaftaran\V1\Rest\KontakPengantarPasien\Service as KontakPengantarPasienService;
use Pendaftaran\V1\Rest\KartuIdentitasPengantarPasien\Service as KartuIdentitasPengantarPasienService;

class Service extends DBService
{
    private $kontakpengantarpasien;
	private $kartuidentitaspengantarpasien;
    
    public function __construct() {
		$this->config["entityName"] = "Pendaftaran\\V1\\Rest\\PengantarPasien\\PengantarPasienEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("pengantar_pasien", "pendaftaran"));
		$this->entity = new PengantarPasienEntity();
		
		$this->kontakpengantarpasien = new KontakPengantarPasienService(); 
		$this->kartuidentitaspengantarpasien = new KartuIdentitasPengantarPasienService();
    }
    
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		foreach($data as &$entity) {
			$kontaks = $this->kontakpengantarpasien->load(['ID' => $entity['ID']]);
			if(count($kontaks) > 0) $entity['KONTAK'] = $kontaks;

			$kartus = $this->kartuidentitaspengantarpasien->load(['PENGANTAR_ID'=>$entity['ID']]);
			if(count($kartus) > 0) $entity['KARTU_IDENTITAS'] = $kartus;	
		}
		
		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(isset($params['NAMA'])) {
			if(!System::isNull($params, 'NAMA')) {
				$select->where->like('NAMA', '%'.$params['NAMA'].'%');
				unset($params['NAMA']);
			}
		}
	}

	protected function onAfterSaveCallback($id, $data) {
		$this->simpanKartuIdentitasPengantarPasien($data, $id);
		$this->simpanKontakPengantarPasien($data, $id);
	}
	
	private function simpanKontakPengantarPasien($data, $id) {
		if(isset($data['KONTAK'])) {
			foreach($data['KONTAK'] as $val) {
				$val['ID'] = $id;
				$this->kontakpengantarpasien->simpan($val); 
			}
		}
	}
	
	private function simpanKartuIdentitasPengantarPasien($data, $id) {
		if(isset($data['KARTU_IDENTITAS'])) {
			foreach($data['KARTU_IDENTITAS'] as $val) {
				$val['PENGANTAR_ID'] = $id;
				$created = empty($val['ID']) ? true : !is_numeric($val['ID']);
				$this->kartuidentitaspengantarpasien->simpanData($val, $created); 
			}
		}
	}

	public function getById($id) {
		$finds = $this->load([
			"ID" => $id
		]);
		if(count($finds) > 0) return $finds[0];
		return null;
	}

	public function getByNoPendafaran($nopen) {
		$finds = $this->load([
			"NOPEN" => $nopen
		]);
		if(count($finds) > 0) return $finds[0];
		return null;
	}

	public function isExists($data) {
		$params = [
			"NOPEN" => $data["NOPEN"],
			"REF" => $data["REF"],
			"SHDK" => $data["SHDK"],
			"JENIS_KELAMIN" => $data["JENIS_KELAMIN"]
		];
		$finds = $this->load($params);
		if(count($finds) > 0) return $finds[0];
		return false;
	}
}