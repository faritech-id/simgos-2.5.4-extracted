<?php
namespace General\V1\Rest\PPK;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;

use General\V1\Rest\Referensi\ReferensiService;

class PPKService extends Service
{
	private $referensi;

	protected $references = [
		'Referensi' => true		
	];
	
    public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "General\\V1\\Rest\\PPK\\PPKEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("ppk", "master"));
		$this->entity = new PPKEntity();
		
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
					// get referensi jenis
					$results = $this->parseReferensi($entity, "jenis");
					if(count($results) > 0) $entity["REFERENSI"]["JENIS"] = $results;

					// get referensi kepemilikan
					$results = $this->parseReferensi($entity, "kepemilikan");
					if(count($results) > 0) $entity["REFERENSI"]["KEPEMILIKAN"] = $results;
					
					// get referensi jenis pelayanan
					$results = $this->parseReferensi($entity, "jpk");
					if(count($results) > 0) $entity["REFERENSI"]["JPK"] = $results;

					$referensi = $this->referensi->load(['JENIS' => 29,'ID' => $entity['JPK']]);
					if(count($referensi) > 0) $entity['REFERENSI']['JPK'] = $referensi[0];
				}
			}
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

		if(!System::isNull($params, 'ID')) {
			$status = $params['ID'];
			$params['ppk.ID'] = (int) $status;
			unset($params['ID']);
		}
		
		if(isset($params['QUERY'])) {
			if(!System::isNull($params, 'QUERY')) {
				$params[] = new \Laminas\Db\Sql\Predicate\Expression("(KODE LIKE ? OR BPJS LIKE ? OR NAMA LIKE ?)",[$params["QUERY"]."%", $params["QUERY"]."%", "%".$params["QUERY"]."%"]);
				unset($params['QUERY']);
			}
		}

		if($this->includeReferences) {
			if($this->references['Referensi']) {
				$fields = $this->referensi->getEntity()->getFieldWithAlias("jenis");
				$select->join(
					["jenis" => new TableIdentifier('referensi', 'master')],
					new \Laminas\Db\Sql\Predicate\Expression("jenis.ID = ppk.JENIS AND jenis.JENIS = 11"),
					$fields,
					Select::JOIN_LEFT
				);
				$fields = $this->referensi->getEntity()->getFieldWithAlias("kepemilikan");
				$select->join(
					["kepemilikan" => new TableIdentifier('referensi', 'master')],
					new \Laminas\Db\Sql\Predicate\Expression("kepemilikan.ID = ppk.KEPEMILIKAN AND kepemilikan.JENIS = 28"),
					$fields,
					Select::JOIN_LEFT
				);
				$fields = $this->referensi->getEntity()->getFieldWithAlias("jpk");
				$select->join(
					["jpk" => new TableIdentifier('referensi', 'master')],
					new \Laminas\Db\Sql\Predicate\Expression("jpk.ID = ppk.JPK AND jpk.JENIS = 29"),
					$fields,
					Select::JOIN_LEFT
				);
			}
		}
	}
}
