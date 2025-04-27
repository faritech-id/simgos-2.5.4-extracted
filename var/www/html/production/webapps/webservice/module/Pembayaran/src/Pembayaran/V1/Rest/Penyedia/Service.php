<?php
namespace Pembayaran\V1\Rest\Penyedia;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;
use General\V1\Rest\Referensi\ReferensiService;

class Service extends DBService {
	private $referensi;
	
	protected $references = [
		"Referensi" => true,
	];
	
	public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "Pembayaran\\V1\\Rest\\Penyedia\\PenyediaEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("penyedia", "pembayaran"));
		$this->entity = new PenyediaEntity();
		$this->limit = 1000;

		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {
			if($this->references['Referensi']) $this->referensi = new ReferensiService();
		}
	}
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);

		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['Referensi']) {
					$result = $this->referensi->load(["JENIS" => 171, 'ID' => $entity['JENIS_PENYEDIA_ID']]);
					if(count($result) > 0) $entity['REFERENSI']['JENIS_PENYEDIA'] = $result[0];

					if(!empty($entity['REFERENSI_ID'])) {
						$result = $this->referensi->load(["JENIS" => 16, 'ID' => $entity['REFERENSI_ID']]);
						if(count($result) > 0) $entity['REFERENSI']['DATA_REFERENSI'] = $result[0];
					}
				}
			}
		}
		
		return $data;
	}
}