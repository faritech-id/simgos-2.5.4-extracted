<?php
namespace Kemkes\RSOnline\V1\Rest\DataTempatTidur;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use Kemkes\RSOnline\db\referensi\tempat_tidur\Service as TempatTidurService;

class Service extends DBService {
	private $tempatTidur;

	protected $references = [
		'TempatTidur' => true,
	];

	public function __construct($includeReferences = true, $references = []) {
        $this->config["entityName"] = "Kemkes\\RSOnline\\V1\\Rest\\DataTempatTidur\\DataTempatTidurEntity";
		$this->config["entityId"] = "id";
		$this->config["autoIncrement"] = false;
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("data_tempat_tidur", "kemkes-rsonline"));
		$this->entity = new DataTempatTidurEntity();

		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;

		if($includeReferences) {
			if($this->references['TempatTidur']) $this->tempatTidur = new TempatTidurService();
        }
	}
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		
		if($this->includeReferences) {
            foreach($data as &$entity) {
                if($this->references['TempatTidur']) {
                    $referensi = $this->tempatTidur->load(['kode_tt' => $entity['id_tt']]);
                    if(count($referensi) > 0) $entity['REFERENSI']['TempatTidur'] = $referensi[0];
				}	
            }
        }
		
		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {		
		$select->join(['ref'=>new TableIdentifier('tempat_tidur', 'kemkes-rsonline')], 'ref.kode_tt = data_tempat_tidur.id_tt', []);
		$select->where("ref.status = 1");
	}

	public function hapus($params = []) {
		$this->table->delete($params);
		return true;
	}
}