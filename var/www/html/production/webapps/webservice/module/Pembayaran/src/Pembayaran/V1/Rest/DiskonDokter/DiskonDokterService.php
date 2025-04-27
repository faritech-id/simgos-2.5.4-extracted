<?php
namespace Pembayaran\V1\Rest\DiskonDokter;

use DBService\DatabaseService;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;
use Laminas\Db\Sql\TableIdentifier;

use General\V1\Rest\Dokter\DokterService;

class DiskonDokterService extends Service
{
	private $dokter;
	
    public function __construct() {
		$this->config["entityName"] = "Pembayaran\\V1\\Rest\\DiskonDokter\\DiskonDokterEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("diskon_dokter", "pembayaran"));
		$this->entity = new DiskonDokterEntity();
		
		$this->dokter = new DokterService();
    }
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		foreach($data as &$entity) {
			$dokter = $this->dokter->load(['ID' => $entity['DOKTER']]);
			if(count($dokter) > 0) $entity['REFERENSI']['DOKTER'] = $dokter[0];		
		}
		
		return $data;
	}
}
