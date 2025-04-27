<?php
namespace General\V1\Rest\KIP;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;
use General\V1\Rest\Wilayah\WilayahService;

class KIPService extends Service
{
	private $wilayahService;
    public function __construct() {
		$this->config["entityName"] = "General\\V1\\Rest\\KIP\\KIPEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("kartu_identitas_pasien", "master"));
		$this->entity = new KIPEntity();	
		$this->wilayahService = new WilayahService();
    }

	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		
		foreach($data as &$entity) {
			if(isset($entity['WILAYAH'])) {
				$length = strlen($entity['WILAYAH']);
				$jenis = ($length > 6) ? 4 : $length / 2; 
				$wilayahService = $this->wilayahService->load(['ID' => $entity['WILAYAH'], 'JENIS' => $jenis, 'TURUNAN' => "1"]);
				if(count($wilayahService) > 0) $entity['REFERENSI']['WILAYAH'] = $wilayahService[0];
			}
		}
		
		return $data;
	}

	public function simpanData($data, $isCreated = false, $loaded = true) {
	    $data = is_array($data) ? $data : (array) $data;
	    $entity = $this->config["entityName"];
	    $this->entity = new $entity();
	    $this->entity->exchangeArray($data);

		$params = [
			"NORM" => $data["NORM"], 
			"JENIS" => $data["JENIS"]
		];

		$finds = $this->load($params);
		if(count($finds) == 0) {
			$this->table->insert($this->entity->getArrayCopy());
		} else {
			$this->table->update($this->entity->getArrayCopy(), $params);
		}
		
	    if($loaded) return $this->load($params);
	    return $params;
	}
}