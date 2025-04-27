<?php
namespace Inventory\V1\Rest\PenggolonganBarang;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as dbService;
use General\V1\Rest\Referensi\ReferensiService;

class Service extends dbService{
    private $referensi;
    public function __construct($includeReferences = true, $references = []){
        $this->config["entityName"] = "\\Inventory\\V1\\Rest\\PenggolonganBarang\\PenggolonganBarangEntity";
        $this->config["entityId"] = "ID";
        $this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("penggolongan_barang","inventory"));
        $this->entity = new PenggolonganBarangEntity();
        
        $this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		$this->referensi = new ReferensiService();
    }

    public function load($params = array(), $columns = array('*'), $orders = array()) {
		$data = parent::load($params, $columns, $orders);
		foreach($data as &$entity) {
            $referensi = $this->referensi->load(array('JENIS' => 149, 'ID' => $entity['PENGGOLONGAN']));
			if(count($referensi) > 0) $entity['REFERENSI']['PENGGOLONGAN'] = $referensi[0];
		}
				
		return $data;
	}
}