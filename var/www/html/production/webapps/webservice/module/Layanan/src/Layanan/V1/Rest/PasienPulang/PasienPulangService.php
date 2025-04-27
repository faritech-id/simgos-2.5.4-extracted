<?php
namespace Layanan\V1\Rest\PasienPulang;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;
use Laminas\Db\Sql\Select;
use Laminas\Db\Sql\Expression;
use DBService\System;

use General\V1\Rest\Dokter\DokterService;
use General\V1\Rest\Referensi\ReferensiService;
use General\V1\Rest\Diagnosa\DiagnosaService;

class PasienPulangService extends Service
{
	private $dokter;
	private $referensi;
	private $diagnosa;
	
	protected $references = [
		'Dokter' => true,
		'Cara' => true,
		'Keadaan' => true,
		'Diagnosa' => true
	];
	
    public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "Layanan\\V1\\Rest\\PasienPulang\\PasienPulangEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("pasien_pulang", "layanan"));
		$this->entity = new PasienPulangEntity();
		
		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
				
		if($includeReferences) {
			$this->referensi = new ReferensiService();
			if($this->references['Dokter']) $this->dokter = new DokterService();
			if($this->references['Diagnosa']) $this->diagnosa = new DiagnosaService();			
		}
    }
        
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
	
		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['Dokter']) {
					$dokter = $this->dokter->load(['ID' => $entity['DOKTER']]);
					if(count($dokter) > 0) $entity['REFERENSI']['DOKTER'] = $dokter[0];
				}
				
				if($this->references['Cara']) {
					$cara = $this->referensi->load(['ID' => $entity['CARA'], 'JENIS' => 45]);
					if(count($cara) > 0) $entity['REFERENSI']['CARA'] = $cara[0];
				}
				
				if($this->references['Keadaan']) {
					$keadaan = $this->referensi->load(['ID' => $entity['KEADAAN'], 'JENIS' => 46]);
					if(count($keadaan) > 0) $entity['REFERENSI']['KEADAAN'] = $keadaan[0];
				}
				
				if($this->references['Diagnosa']) {
					if(isset($entity['DIAGNOSA'])) {
						$diagnosa = $this->diagnosa->load(['CODE' => $entity['DIAGNOSA']]);
						if(count($diagnosa) > 0) $entity['REFERENSI']['DIAGNOSA'] = $diagnosa[0];
					}
				}
			}
		}
				
		return $data;
	}
}