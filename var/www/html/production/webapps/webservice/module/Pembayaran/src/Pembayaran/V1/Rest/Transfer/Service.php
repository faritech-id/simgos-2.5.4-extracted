<?php
namespace Pembayaran\V1\Rest\Transfer;
use DBService\DatabaseService;
use Laminas\Db\Sql\Select;
use Laminas\Db\Sql\TableIdentifier;
use DBService\System;
use DBService\generator\Generator;
use DBService\Service as dbService;
use General\V1\Rest\Referensi\ReferensiService;
use General\V1\Rest\Rekening\Service as rekeningService;

class Service extends dbService {
	private $referensi;
	private $rekening;
    public function __construct($includereferences = true, $references = array()) {
        $this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("transfer", "pembayaran"));
		$this->entity = new TransferEntity();

        $this->config["entityName"] = "\\Pembayaran\\V1\\Rest\\Transfer\\TransferEntity";
        $this->config["entityId"] = "ID";

		$this->referensi = new ReferensiService();
		$this->rekening = new rekeningService();
	}
	
	public function load($params = array(), $columns = array('*'), $orders = array()) {
		$data = parent::load($params, $columns, $orders);

		foreach($data as &$entity) {
			$referensi = $this->referensi->load(array('ID' => $entity['BANK_ASAL'], 'JENIS' => 16));
			if(count($referensi) > 0) $entity['REFERENSI']['BANK_ASAL'] = $referensi[0];

			$rekening = $this->rekening->load(array('ID' => $entity['REKENING']));
			if(count($rekening) > 0) $entity['REFERENSI']['REKENING'] = $rekening[0];
		}
		
		return $data;
	}
}