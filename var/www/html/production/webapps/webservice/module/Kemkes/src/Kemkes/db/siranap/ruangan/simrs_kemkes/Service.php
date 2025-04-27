<?php
namespace Kemkes\db\siranap\ruangan\simrs_kemkes;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

use Kemkes\db\siranap\ruangan\Service as RuanganKemkesService;
use General\V1\Rest\Ruangan\RuanganService as RuanganSimrsService;

class Service extends DBService {
	protected $limit = 3000;

	private $kemkes;
	private $simrs;

	protected $references = array(
		'RuanganKemkes' => true,
		'RuanganSimrs' => true
	);
	
	public function __construct($includeReferences = true, $references = array()) {
		$this->config["entityName"] = "Kemkes\\db\\siranap\\ruangan\\simrs_kemkes\\Entity";
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("ruangan_simrs_kemkes", "master"));

		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {
			if($this->references['RuanganKemkes']) $this->kemkes = new RuanganKemkesService();
			if($this->references['RuanganSimrs']) $this->simrs = new RuanganSimrsService(false);
		}
	}
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		
		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['RuanganKemkes']) {
					$ruangan = $this->kemkes->load(['ID' => $entity['KEMKES_RUANGAN']]);
					if(count($ruangan) > 0) $entity['REFERENSI']['RUANGAN_KEMKES'] = $ruangan[0];
				}

				if($this->references['RuanganSimrs']) {
					$ruangan = $this->simrs->load(['JENIS_KUNJUNGAN' => 3, 'JENIS' => 5, 'ID' => $entity['RUANGAN']], ["ID", "DESKRIPSI"]);
					if(count($ruangan) > 0) $entity['REFERENSI']['RUANGAN_SIMRS'] = $ruangan[0];
				}
			}
		}
		
		return $data;
	}
}