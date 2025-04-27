<?php
namespace General\V1\Rest\FrekuensiAturanResep;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;
use Laminas\Db\Sql\Select;
use Zend\json\Json;
use DBService\System;
class FrekuensiAturanResepService extends Service
{
	protected $limit = 1000;
	
    public function __construct() {
        $this->config["entityName"] = "General\\V1\\Rest\\FrekuensiAturanResep\\FrekuensiAturanResepEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("frekuensi_aturan_resep", "master"));
        $this->entity = new FrekuensiAturanResepEntity();
    }

    protected function queryCallback(Select &$select, &$params, $columns, $orders) {
        if(isset($params['QUERY'])) {
			if(!System::isNull($params, 'QUERY')) {
				$select->where->like('FREKUENSI', $params['QUERY'].'%');
				unset($params['QUERY']);
			}
		}
	}
}