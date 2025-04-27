<?php
namespace BPJService\db\tempat_tidur;

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
		$this->config["entityName"] = "BPJService\\db\\tempat_tidur\\Entity";
		$this->config["entityId"] = "id";
		$this->table = DatabaseService::get('BPJS')->get(new TableIdentifier("tempat_tidur", "bpjs"));
		
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
					$kelas = $this->ruangKamar->load(array('kodekelas' => $entity['kodekelas']));
					if(count($kelas) > 0) $entity['REFERENSI']['KELAS'] = $kelas[0];
				}
			}
		}
		
		return $data;
	}

	public function executeTempatTidur() {
	    $adapter = $this->table->getAdapter();
	    $stmt = $adapter->query('CALL bpjs.executeTempatTidur()');
	    $results = $stmt->execute([]);
	    $results->getResource()->closeCursor();
	    return array(
	        'success' => true
	    );
	}
	
	public function hapus($params = []) {
		$this->table->delete($params);
		return true;
	}
}