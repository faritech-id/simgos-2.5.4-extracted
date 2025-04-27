<?php
namespace Aplikasi\V1\Rest\Instansi;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;
use General\V1\Rest\PPK\PPKService;

class InstansiService extends Service
{	
    private $PPK;
	
	protected $references = [
		'PPK' => true
	];

    public function __construct($includeReferences = true, $references = []) {
        $this->config["entityName"] = "Aplikasi\\V1\\Rest\\Instansi\\InstansiEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("instansi", "aplikasi"));
		$this->entity = new InstansiEntity();
        
        if($includeReferences) {			
			if($this->references['PPK']) $this->ppk = new PPKService();
		}
	}

    public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		
		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['PPK']) {
					$ppk = $this->ppk->load(['ID' => $entity['PPK']]);
					if(count($ppk) > 0) $entity['REFERENSI']['PPK'] = $ppk[0];
				}
			}
		}
		
		return $data;
	}
}
