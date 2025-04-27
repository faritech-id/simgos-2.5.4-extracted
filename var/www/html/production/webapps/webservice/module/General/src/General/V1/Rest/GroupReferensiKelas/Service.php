<?php
namespace General\V1\Rest\GroupReferensiKelas;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

use General\V1\Rest\Referensi\ReferensiService;

class Service extends DBService {
	private $referensi;

	protected $references = [
		'Referensi' => true
	];

	public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "General\\V1\\Rest\\GroupReferensiKelas\\GroupReferensiKelasEntity";		
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("group_referensi_kelas", "master"));
		
		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {
			if($this->references['Referensi']) $this->referensi = new ReferensiService();
		}
	}

	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		
		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['Referensi']) {
					$referensi = $this->referensi->load(['JENIS' => 19, 'ID' => $entity['REFERENSI_KELAS']]);
					if(count($referensi) > 0) $entity['REFERENSI']['REFERENSI_KELAS'] = $referensi[0];

					$referensi = $this->referensi->load(['JENIS' => 19, 'ID' => $entity['KELAS']]);
					if(count($referensi) > 0) $entity['REFERENSI']['KELAS'] = $referensi[0];
				}
			}
		}
		
		return $data;
	}	
}