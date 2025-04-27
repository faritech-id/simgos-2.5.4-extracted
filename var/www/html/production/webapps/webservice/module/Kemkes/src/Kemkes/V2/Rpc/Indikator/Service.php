<?php
namespace Kemkes\V2\Rpc\Indikator;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;

use General\V1\Rest\Referensi\ReferensiService;
class Service extends DBService
{
    private $referensi;

    protected $references = array(
		'Referensi' => true
	);

    public function __construct($includeReferences = true, $references = array()) {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("statistik_indikator", "informasi"));
        $this->entity = new Entity();

        $this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {
			if($this->references['Referensi']) $this->referensi = new ReferensiService();
		}
    }
	
    public function simpan($data) {
        $data = is_array($data) ? $data : (array) $data;
        $this->entity = new Entity();
        $this->entity->exchangeArray($data);
        
        $params = [
            "TAHUN" => $this->entity->get("TAHUN"),
            "PERIODE" => $this->entity->get("PERIODE"),
            "JENIS" => $this->entity->get("JENIS")
        ];
        $this->table->update($this->entity->getArrayCopy(), $params);
        
        return true;
    }

    public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		
		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['Referensi']) {
                    if($entity["JENIS"] == 1) {
                        $kelas = $this->referensi->load(['JENIS' => 83, 'ID' => $entity['PERIODE']]);
                        if(count($kelas) > 0) $entity['REFERENSI']['PERIODE'] = $kelas[0];
                    } elseif($entity["JENIS"] == 2) {
                        $tws = [
                            "tw1" => "Triwulan I",
                            "tw2" => "Triwulan II",
                            "tw3" => "Triwulan III",
                            "tw4" => "Triwulan IV"
                        ];
                        $entity['REFERENSI']['PERIODE'] = [ "ID" => $entity['PERIODE'], "DESKRIPSI" => $tws[$entity['PERIODE']] ];
                    } else {
                        $entity['REFERENSI']['PERIODE'] = [ "ID" => 0, "DESKRIPSI" => "-" ];
                    }
				}
			}
		}
		
		return $data;
	}
}