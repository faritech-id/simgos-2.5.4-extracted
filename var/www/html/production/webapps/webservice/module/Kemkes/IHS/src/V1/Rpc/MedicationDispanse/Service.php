<?php
namespace Kemkes\IHS\V1\Rpc\MedicationDispanse;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;

class Service extends DBService
{    
    public function __construct($includeReferences = true, $references = []) 
    {
        $this->config["entityName"] = "Kemkes\\IHS\\V1\\Rpc\\MedicationDispanse\\Entity";
        $this->config["autoIncrement"] = false;
        $this->config["entityId"] = "refId";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("medication_dispanse", "kemkes-ihs"));
        $this->entity = new Entity();
    }

    public function simpan($data) {
	    $data = is_array($data) ? $data : (array) $data;
        $this->entity = new Entity();
	    $this->entity->exchangeArray($data);
        
        $params = [
            'refId' => $data['refId'], 
            'barang' => $data['barang'],
            'group_racikan' => $data['group_racikan']
        ];

        $cek = $this->load($params);
        if(count($cek) > 0) $this->table->update($this->entity->getArrayCopy(), $params);

        return $this->load($params);
	}

    protected function queryCallback(Select &$select, &$params, $columns, $orders) {
        $select->join(['p'=>new TableIdentifier('pendaftaran', 'pendaftaran')], 'p.NOMOR = medication_dispanse.nopen', []);
        
        if(!System::isNull($params, 'TANGGAL')) {
            $select->where->between("p.TANGGAL", $params["TANGGAL"]." 00:00:00", $params["TANGGAL"]." 23:59:59");
            unset($params['TANGGAL']);
        }
	}
	
}