<?php
namespace Layanan\V1\Rest\HasilEvaluasiSST;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use DBService\generator\Generator;
use Pendaftaran\V1\Rest\Kunjungan\KunjunganService;
use Aplikasi\V1\Rest\Pengguna\PenggunaService;
use General\V1\Rest\Dokter\DokterService;

class Service extends DBService {
	
	private $dokter;

	public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "Layanan\\V1\\Rest\\HasilEvaluasiSST\\HasilEvaluasiSSTEntity";
		$this->config["autoIncrement"] = false;
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("hasil_evaluasi_sst", "layanan"));
		
		$this->entity = new HasilEvaluasiSSTEntity();		
		$this->dokter = new DokterService();
	}
	
	public function load($params = array(), $columns = array('*'), $orders = array()) {
		$data = parent::load($params, $columns, $orders);
		foreach($data as &$entity) {			
			$dokter = $this->dokter->load(array('ID' => $entity['DOKTER']));
			if(count($dokter) > 0) $entity['REFERENSI']['DOKTER'] = $dokter[0];
		}
		
		return $data;
	}

	protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
		if($isCreated) $entity->set('ID', Generator::generateIdHasilEvaluasiSST());
	}
}