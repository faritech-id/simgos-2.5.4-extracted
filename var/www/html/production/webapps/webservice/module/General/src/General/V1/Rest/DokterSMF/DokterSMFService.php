<?php
namespace General\V1\Rest\DokterSMF;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use Zend\json\Json;
use DBService\System;
use DBService\Service;

class DokterSMFService extends Service
{
    public function __construct() {
		$this->config["entityName"] = "General\\V1\\Rest\\DokterSMF\\DokterSMFEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("dokter_smf", "master"));
		$this->entity = new DokterSMFEntity();
    }
    
	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'STATUS')) {
			$params['dokter_smf.STATUS'] = $params['STATUS'];
			unset($params['STATUS']);
		}
		if(!System::isNull($params, 'NIP')) { 
			$select->join(
				['d' => new TableIdentifier("dokter", "master")], 
				"dokter_smf.DOKTER = d.ID", 
				[]
			);
			$params['d.NIP'] = $params['NIP'];
			unset($params['NIP']);
		}
	}
}