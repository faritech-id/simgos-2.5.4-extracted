<?php
namespace Kemkes\RSOnline\V1\Rest\DataKebutuhanSDM;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

use Kemkes\RSOnline\db\referensi\kebutuhan_sdm\Service as KebutuhanSDMService;

class Service extends DBService {
	private $kebutuhanSDM;

	protected $references = [
		'KebutuhanSDM' => true,
	];

	public function __construct($includeReferences = true, $references = []) {
        $this->config["entityName"] = "Kemkes\\RSOnline\\V1\\Rest\\DataKebutuhanSDM\\DataKebutuhanSDMEntity";
		$this->config["entityId"] = "id_kebutuhan";
		$this->config["autoIncrement"] = false;
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("data_kebutuhan_sdm", "kemkes-rsonline"));
		$this->entity = new DataKebutuhanSDMEntity();

		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;

		if($includeReferences) {
			if($this->references['KebutuhanSDM']) $this->kebutuhanSDM = new KebutuhanSDMService();
        }
	}
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		
		if($this->includeReferences) {
            foreach($data as &$entity) {
                if($this->references['KebutuhanSDM']) {
                    $referensi = $this->kebutuhanSDM->load(['id_kebutuhan' => $entity['id_kebutuhan']]);
                    if(count($referensi) > 0) $entity['REFERENSI']['KebutuhanSDM'] = $referensi[0];
				}	
            }
        }
		
		return $data;
	}
}