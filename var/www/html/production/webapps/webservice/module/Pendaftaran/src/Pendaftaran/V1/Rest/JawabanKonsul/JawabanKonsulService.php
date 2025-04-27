<?php
namespace Pendaftaran\V1\Rest\JawabanKonsul;

use DBService\DatabaseService;
use Laminas\Db\Sql\Select;
use DBService\generator\Generator;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Expression;
use Zend\json\Json;
use DBService\System;
use DBService\Service;

use Pendaftaran\V1\Rest\Konsul\KonsulService;
use General\V1\Rest\Dokter\DokterService;

class JawabanKonsulService extends Service
{   
	private $konsul;
	
    public function __construct() {
		$this->config["entityName"] = "Pendaftaran\\V1\\Rest\\JawabanKonsul\\JawabanKonsulEntity";
		$this->config["entityId"] = "NOMOR";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("jawaban_konsul", "pendaftaran"));
		$this->entity = new JawabanKonsulEntity();
		
		$this->konsul = new KonsulService();
		$this->dokter = new DokterService();
    }
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		
		foreach($data as &$entity) {
			$konsul = $this->konsul->load(['NOMOR' => $entity['KONSUL_NOMOR']]);
			if(count($konsul) > 0) $entity['REFERENSI']['KONSUL'] = $konsul[0];
			
			$dokter = $this->dokter->load(['ID' => $entity['DOKTER']]);
			if(count($dokter) > 0) $entity['REFERENSI']['DOKTER'] = $dokter[0];
		}
		
		return $data;
	}
}