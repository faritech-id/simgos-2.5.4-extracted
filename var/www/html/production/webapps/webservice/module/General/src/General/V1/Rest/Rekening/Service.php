<?php
namespace General\V1\Rest\Rekening;
use DBService\DatabaseService;
use Laminas\Db\Sql\Select;
use Laminas\Db\Sql\TableIdentifier;
use DBService\System;
use DBService\generator\Generator;
use DBService\Service as dbService;
use General\V1\Rest\Referensi\ReferensiService;

class Service extends dbService {
	private $referensi;
	protected $references = [
		'Referensi' => true		
	];
	
    public function __construct($includereferences = true, $references = []) {
        $this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("rekening", "master"));
        $this->entity = new RekeningEntity(); 
        
        $this->config["entityName"] = "\\General\\V1\\Rest\\Rekening\\RekeningEntity";
        $this->config["entityId"] = "ID";

		$this->referensi = new ReferensiService();
	}
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);

		foreach($data as &$entity) {
			$referensi = $this->referensi->load(['ID' => $entity['BANK'], 'JENIS' => 16]);
			if(count($referensi) > 0) $entity['REFERENSI']['BANK'] = $referensi[0];
			
			$js_rekening = $this->referensi->load(['ID' => $entity['JENIS'], 'JENIS' => 173]);
			if(count($js_rekening) > 0) $entity['REFERENSI']['JENIS_REKENING'] = $js_rekening[0];	
		}
		return $data;
	}


	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(isset($params['PEMILIK'])) {
			if(!System::isNull($params, 'PEMILIK')) {
				$select->where->like('PEMILIK', '%'.$params['PEMILIK'].'%');
				unset($params['PEMILIK']);
			}
		}
		
		if(isset($params['QUERY'])) {
			if(!System::isNull($params, 'QUERY')) {
				$params[] = new \Laminas\Db\Sql\Predicate\Expression("(NOMOR = ? OR PEMILIK LIKE ?)", [$params["QUERY"], $params["QUERY"]."%"]);
				unset($params['QUERY']);
			}
		}
	}
}
