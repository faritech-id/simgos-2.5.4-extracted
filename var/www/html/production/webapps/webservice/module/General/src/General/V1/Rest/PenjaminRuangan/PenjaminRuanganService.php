<?php
namespace General\V1\Rest\PenjaminRuangan;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use DBService\generator\Generator;
use General\V1\Rest\Referensi\ReferensiService;
use General\V1\Rest\Ruangan\RuanganService;


class PenjaminRuanganService extends DBService
{
	private $referensi;
	private $ruangan;
	private $penjamin;

	protected $references = array(
		'Referensi' => true,
		'Ruangan' => true,
		'Penjamin' => true
	);
	
    public function __construct($includeReferences = true, $references = array()) {
		$this->config["entityName"] = "General\\V1\\Rest\\PenjaminRuangan\\PenjaminRuanganEntity";
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("penjamin_ruangan", "master"));
		$this->entity = new PenjaminRuanganEntity();

		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {
			if($this->references['Referensi']) $this->referensi = new ReferensiService();
			if($this->references['Ruangan']) $this->ruangan = new RuanganService(true, array(
				'Referensi' => true,
				'PenjaminRuangan' => false
			));
		}
		$this->limit = 500;
    }

	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);

		if($this->includeReferences) {
			foreach($data as &$entity) {				
				if($this->references['Referensi']) {
					$penjamin = $this->referensi->load(array('JENIS' => 10, 'ID' => $entity['PENJAMIN']));
					if(count($penjamin) > 0) $entity['REFERENSI']['PENJAMIN'] = $penjamin[0];
				}
				
				if($this->references['Ruangan']) {
					if(!empty($entity['RUANGAN_RS'])){
						$ruangan = $this->ruangan->load(['JENIS' => 5, 'ID' => $entity['RUANGAN_RS']]);
						if(count($ruangan) > 0) $entity['REFERENSI']['RUANGAN_RS'] = $ruangan[0];
					}
				}
			}
		}
		return $data;
	}
}
