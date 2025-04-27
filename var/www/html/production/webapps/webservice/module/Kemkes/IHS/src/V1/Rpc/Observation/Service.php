<?php
namespace Kemkes\IHS\V1\Rpc\Observation;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;

class Service extends DBService
{    
    public function __construct($includeReferences = true, $references = []) 
    {
        $this->config["entityName"] = "Kemkes\\IHS\\V1\\Rpc\\Observation\\Entity";
        $this->config["autoIncrement"] = false;
        $this->config["entityId"] = "nopen";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("observation", "kemkes-ihs"));
        $this->entity = new Entity();
    }

    protected function queryCallback(Select &$select, &$params, $columns, $orders) {
        $select->join(['p'=>new TableIdentifier('pendaftaran', 'pendaftaran')], 'p.NOMOR = observation.nopen', []);
        
        if(!System::isNull($params, 'TANGGAL')) {
            $select->where->between("p.TANGGAL", $params["TANGGAL"]." 00:00:00", $params["TANGGAL"]." 23:59:59");
            unset($params['TANGGAL']);
        }
	}

    public function simpan($data) {
	    $data = is_array($data) ? $data : (array) $data;       
        $this->entity = new Entity();  
	    $this->entity->exchangeArray($data);

        $params = [
            'refId' => $this->entity->get('refId'), 
            'jenis' => $this->entity->get('jenis')
        ];

        $this->table->update($this->entity->getArrayCopy(), $params);

        return $this->load($params);
	}
	
}