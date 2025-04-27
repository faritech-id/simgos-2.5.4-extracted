<?php
namespace Kemkes\db\siranap\kelas\simrs_kemkes;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

use Kemkes\db\siranap\kelas\Service as KelasService;
use General\V1\Rest\Referensi\ReferensiService;

class Service extends DBService {
	protected $limit = 3000;

	private $kelas;
	private $referensi;

	protected $references = array(
		'Kelas' => true,
		'Referensi' => true
	);
	
	public function __construct($includeReferences = true, $references = array()) {
		$this->config["entityName"] = "Kemkes\\db\\siranap\\kelas\\simrs_kemkes\\Entity";
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("kelas_simrs_kemkes", "master"));

		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {
			if($this->references['Kelas']) $this->kelas = new KelasService();
			if($this->references['Referensi']) $this->referensi = new ReferensiService();
		}
	}
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		
		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['Kelas']) {
					$kelas = $this->kelas->load(['ID' => $entity['KEMKES_KELAS']]);
					if(count($kelas) > 0) $entity['REFERENSI']['KELAS_KEMKES'] = $kelas[0];
				}

				if($this->references['Referensi']) {
					$kelas = $this->referensi->load(['JENIS' => 19, 'ID' => $entity['KELAS']]);
					if(count($kelas) > 0) $entity['REFERENSI']['KELAS_SIMRS'] = $kelas[0];
				}
			}
		}
		
		return $data;
	}
}