<?php
namespace BPJService\db\map_kelas;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;
use BPJService\db\referensi\kamar\Service as RuangKamarService;

class Service extends DBService {
	private $ruangKamar;

	protected $references = array(
		'RuangKamar' => true
	);

	public function __construct($includeReferences = true, $references = array()) {
		$this->config["entityName"] = "BPJService\\db\\map_kelas\\Entity";
		$this->config["entityId"] = "id";
		$this->table = DatabaseService::get('BPJS')->get(new TableIdentifier("map_kelas", "bpjs"));
		
		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {
			if($this->references['RuangKamar']) $this->ruangKamar = new RuangKamarService();
		}
	}

	public function load($params = array(), $columns = array('*'), $orders = array()) {
		$data = parent::load($params, $columns, $orders);
		
		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['RuangKamar']) {
					$kelas = $this->ruangKamar->load(array('kodekelas' => $entity['kelas']));
					if(count($kelas) > 0) $entity['REFERENSI']['KELAS'] = $kelas[0];
				}
			}
		}
		
		return $data;
	}	
}