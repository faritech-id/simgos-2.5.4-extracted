<?php
namespace Kemkes\IHS\V1\Rpc\Practitioner;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;
use Laminas\Db\Sql\Select;
use DBService\System;


class Service extends DBService
{    
    public function __construct($includeReferences = true, $references = []) 
    {
        $this->config["entityName"] = "Kemkes\\IHS\\V1\\Rpc\\Practitioner\\Entity";
        $this->config["autoIncrement"] = false;
        $this->config["entityId"] = "refId";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("practitioner", "kemkes-ihs"));
        $this->entity = new Entity();
    }

    protected function queryCallback(Select &$select, &$params, $columns, $orders) {
        if(!System::isNull($params, 'QUERY')) {
                $select->join(['ki'=>new TableIdentifier('kartu_identitas', 'pegawai' )]
                , new \Laminas\Db\Sql\Predicate\Expression("ki.NOMOR = practitioner.refId AND ki.JENIS = 1")
                , []
            );

            $select->join(['pi'=>new TableIdentifier('pegawai', 'master')]
                , new \Laminas\Db\Sql\Predicate\Expression("ki.NIP = pi.NIP")
                , []
            );
            $params[] = new \Laminas\Db\Sql\Predicate\Expression("(pi.NAMA LIKE ? OR  practitioner.refId LIKE ?)",  ["%".$params["QUERY"]."%", $params["QUERY"]."%"]);
            
            unset($params['QUERY']);
        }
        
        if(!System::isNull($params, 'TANGGAL')) {
            $select->where->between("p.TANGGAL", $params["TANGGAL"]." 00:00:00", $params["TANGGAL"]." 23:59:59");
            unset($params['TANGGAL']);
        }
	}
}