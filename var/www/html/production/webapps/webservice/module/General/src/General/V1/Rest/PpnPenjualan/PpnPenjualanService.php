<?php
namespace General\V1\Rest\PpnPenjualan;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;
use Laminas\Db\Sql\Select;
use DBService\System;

class PpnPenjualanService extends Service
{
	protected $limit = 1000;
	
    public function __construct() {
        $this->config["entityName"] = "General\\V1\\Rest\\PpnPenjualan\\PpnPenjualanEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("ppn_penjualan", "penjualan"));
        $this->entity = new PpnPenjualanEntity();
    }

    protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'STATUS')) {
			$params['ppn_penjualan.STATUS'] = $params['STATUS'];
			unset($params['STATUS']);
		}
        if(!System::isNull($params, 'TANGGAL')) {
            $params[] = new \Laminas\Db\Sql\Predicate\Expression("ppn_penjualan.TANGGAL_MULAI_BERLAKU <= ?", [$params["TANGGAL"]]);
            unset($params['TANGGAL']);
		}
    }
}