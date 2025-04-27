<?php
namespace General\V1\Rest\KAP;

use General\V1\Rest\Referensi\ReferensiService;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;

use BPJService\db\peserta\Service as PesertaBPJService;
use General\V1\Rest\PPK\PPKService;

class KAPService extends Service
{
	private $referensi;
	private $peserta = [];
	private $ppk;
	
    public function __construct() {
		$this->config["entityName"] = "General\\V1\\Rest\\KAP\\KAPEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("kartu_asuransi_pasien", "master"));
		$this->entity = new KAPEntity();
		
		$this->referensi = new ReferensiService();
		$this->peserta[2] = new PesertaBPJService();
		$this->ppk = new PPKService();
    }
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);		
		foreach($data as &$entity) {
			$penjamin = $this->referensi->load(['JENIS' => 10, 'ID' => $entity['JENIS']]);
			if(count($penjamin) > 0) $entity['REFERENSI']['PENJAMIN'] = $penjamin[0];
			
			if(isset($this->peserta[$entity['JENIS']])) {
			    if($entity['JENIS'] == 2) {
			        $psrt = $this->peserta[$entity['JENIS']]->load(["noKartu" => $entity['NOMOR']]);
			        if(count($psrt) > 0) {
			            $ppk = $this->ppk->load(["BPJS" => $psrt[0]["kdProvider"]]);
			            if(count($ppk) > 0) $entity['REFERENSI']['PPK'] = $ppk[0];
			            //$entity['REFERENSI']['PESERTA'] = $psrt[0];
			        }
			    }
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
