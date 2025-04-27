<?php
namespace Pendaftaran\V1\Rest\PenanggungJawabPasien;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use Zend\json\Json;
use DBService\System;
use DBService\Service;
use Pendaftaran\V1\Rest\KontakPenanggungJawab\KontakPenanggungJawabService;
use Pendaftaran\V1\Rest\KIPPenanggungJawab\KIPPenanggungJawabService;

class PenanggungJawabPasienService extends Service
{
    private $kontakpenanggungjawab;
	private $kippenanggungjawab;
    
    public function __construct() {
		$this->config["entityName"] = "Pendaftaran\\V1\\Rest\\PenanggungJawabPasien\\PenanggungJawabPasienEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("penanggung_jawab_pasien", "pendaftaran"));
		$this->entity = new PenanggungJawabPasienEntity();
		
		$this->kontakpenanggungjawab = new KontakPenanggungJawabService(); 
		$this->kippenanggungjawab = new KIPPenanggungJawabService();
    }
    
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		foreach($data as &$entity) {
			$kontaks = $this->kontakpenanggungjawab->load(['ID' => $entity['ID']]);
			if(count($kontaks) > 0) $entity['KONTAK'] = $kontaks;

			$kartus = $this->kippenanggungjawab->load(['PENANGGUNG_JAWAB_ID'=>$entity['ID']]);
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
		$this->simpanKIPenanggung($data, $id);
		$this->simpanKontakPenanggung($data, $id);
	}

	private function simpanKontakPenanggung($data, $id) {
		if(isset($data['KONTAK'])) {
			foreach($data['KONTAK'] as $val) {
				$val['ID'] = $id;
				$this->kontakpenanggungjawab->simpan($val); 
			}
		}
	}
	
	private function simpanKIPenanggung($data, $id) {
		if(isset($data['KARTU_IDENTITAS'])) {
			foreach($data['KARTU_IDENTITAS'] as $val) {
				$val['PENANGGUNG_JAWAB_ID'] = $id;
				$created = empty($val['ID']) ? true : !is_numeric($val['ID']);
				$this->kippenanggungjawab->simpanData($val, $created); 
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