<?php
namespace Pembayaran\V1\Rest\LayananPenyedia;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;
use General\V1\Rest\Referensi\ReferensiService;
use Pembayaran\V1\Rest\Penyedia\Service as PenyediaService;

class Service extends DBService {
	private $referensi;
	private $penyedia;
	
	protected $references = [
		"Referensi" => true,
		"Penyedia" => true,
	];

	public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "Pembayaran\\V1\\Rest\\LayananPenyedia\\LayananPenyediaEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("layanan_penyedia", "pembayaran"));
		$this->entity = new LayananPenyediaEntity();

		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {
			if($this->references['Referensi']) $this->referensi = new ReferensiService();
			if($this->references['Penyedia']) $this->penyedia = new PenyediaService();
		}
	}

	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);

		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['Referensi']) {
					$result = $this->referensi->load(["JENIS" => 172, 'ID' => $entity['JENIS_LAYANAN_ID']]);
					if(count($result) > 0) $entity['REFERENSI']['JENIS_LAYANAN'] = $result[0];
				}
				if($this->references['Penyedia']) {
					$result = $this->penyedia->load(['ID' => $entity['PENYEDIA_ID']]);
					if(count($result) > 0) $entity['REFERENSI']['PENYEDIA'] = $result[0];
				}
			}
		}
		
		return $data;
	}
}