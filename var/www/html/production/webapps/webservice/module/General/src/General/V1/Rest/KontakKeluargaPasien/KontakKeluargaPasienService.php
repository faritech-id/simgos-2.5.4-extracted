<?php
namespace General\V1\Rest\KontakKeluargaPasien;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;
use DBService\generator\Generator;

class KontakKeluargaPasienService extends Service
{
    public function __construct() {
		$this->config["entityName"] = "General\\V1\\Rest\\KontakKeluargaPasien\\KontakKeluargaPasienEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("kontak_keluarga_pasien", "master"));
		$this->entity = new KontakKeluargaPasienEntity();	
    }

	public function simpanData($data, $isCreated = false, $loaded = true) {
	    $data = is_array($data) ? $data : (array) $data;
	    $entity = $this->config["entityName"];
	    $this->entity = new $entity();
	    $this->entity->exchangeArray($data);

		$params = [
			"SHDK" => $data["SHDK"],
			"JENIS" => $data["JENIS"],
			"NORM" => $data["NORM"], 
			"NOMOR" => $data["NOMOR"]
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
