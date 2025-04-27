<?php
namespace Kemkes\IHS\V1\Rpc\DiagnosticReport;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;
use Laminas\Db\Sql\Select;
use DBService\System;

class Service extends DBService
{    
    public function __construct($includeReferences = true, $references = []) 
    {
        $this->config["entityName"] = "Kemkes\\IHS\\V1\\Rpc\\DiagnosticReport\\Entity";
        $this->config["autoIncrement"] = false;
        $this->config["entityId"] = "refId";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("diagnostic_report", "kemkes-ihs"));
        $this->entity = new Entity();
    }

    protected function queryCallback(Select &$select, &$params, $columns, $orders) {
        $select->join(['p'=>new TableIdentifier('pendaftaran', 'pendaftaran')], 'p.NOMOR = diagnostic_report.nopen', []);
        
        if(!System::isNull($params, 'TANGGAL')) {
            $select->where->between("p.TANGGAL", $params["TANGGAL"]." 00:00:00", $params["TANGGAL"]." 23:59:59");
            unset($params['TANGGAL']);
        }
	}
}