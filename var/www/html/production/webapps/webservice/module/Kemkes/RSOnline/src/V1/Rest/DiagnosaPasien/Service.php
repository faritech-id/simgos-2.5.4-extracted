<?php
namespace Kemkes\RSOnline\V1\Rest\DiagnosaPasien;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;
use General\V1\Rest\Diagnosa\DiagnosaService;
use Laminas\Db\Sql\Select;

class Service extends DBService {
	public function __construct() {
        $this->config["entityName"] = "Kemkes\\RSOnline\\V1\\Rest\\DiagnosaPasien\\DiagnosaPasienEntity";
		$this->config["entityId"] = "id";
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("diagnosa_pasien", "kemkes-rsonline"));
		
		$this->diagnosa = new DiagnosaService();
	}

	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		
		foreach($data as &$entity) {
			$diagnosa = $this->diagnosa->load(['CODE' => $entity['icd']]);
			if(count($diagnosa) > 0) $entity['REFERENSI']['ICD'] = $diagnosa[0];
		}
				
		return $data;
	}
}