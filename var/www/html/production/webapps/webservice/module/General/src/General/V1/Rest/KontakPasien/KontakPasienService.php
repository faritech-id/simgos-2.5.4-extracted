<?php
namespace General\V1\Rest\KontakPasien;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\System;
use DBService\Service;

class KontakPasienService extends Service
{
    public function __construct() {
		$this->config["entityName"] = "General\\V1\\Rest\\KontakPasien\\KontakPasienEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("kontak_pasien", "master"));
		$this->entity = new KontakPasienEntity();
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
