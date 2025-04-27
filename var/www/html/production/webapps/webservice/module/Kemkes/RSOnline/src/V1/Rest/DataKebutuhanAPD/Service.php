<?php
namespace Kemkes\RSOnline\V1\Rest\DataKebutuhanAPD;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

use Kemkes\RSOnline\db\referensi\kebutuhan_apd\Service as KebutuhanAPDService;

class Service extends DBService {
	private $kebutuhanAPD;

	protected $references = [
		'KebutuhanAPD' => true,
	];

	public function __construct($includeReferences = true, $references = []) {
        $this->config["entityName"] = "Kemkes\\RSOnline\\V1\\Rest\\DataKebutuhanAPD\\DataKebutuhanAPDEntity";
		$this->config["entityId"] = "id_kebutuhan";
		$this->config["autoIncrement"] = false;
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("data_kebutuhan_apd", "kemkes-rsonline"));
		$this->entity = new DataKebutuhanAPDEntity();

		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;

		if($includeReferences) {
			if($this->references['KebutuhanAPD']) $this->kebutuhanAPD = new KebutuhanAPDService();
        }
	}
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		
		if($this->includeReferences) {
            foreach($data as &$entity) {
                if($this->references['KebutuhanAPD']) {
                    $referensi = $this->kebutuhanAPD->load(['id_kebutuhan' => $entity['id_kebutuhan']]);
                    if(count($referensi) > 0) $entity['REFERENSI']['KebutuhanAPD'] = $referensi[0];
				}	
            }
        }
		
		return $data;
	} 
}