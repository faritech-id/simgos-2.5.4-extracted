<?php
namespace MedicalRecord\V1\Rest\PenandaGambarDetail;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;

class Service extends DBService {
	
	public function __construct($includeReferences = true, $references = array()) {
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\PenandaGambarDetail\\PenandaGambarDetailEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("penanda_gambar_detail", "medicalrecord"));
		$this->entity = new PenandaGambarDetailEntity();
		
		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
	}

    public function simpan($data, $isCreated = false, $loaded = true) {
		$data = is_array($data) ? $data : (array) $data;
		$this->entity = new PenandaGambarDetailEntity();
		$this->entity->exchangeArray($data);
		
		if($isCreated) {
			$cek = $this->load(array("PENANDA" => $this->entity->get("PENANDA"), "NOMOR"=>$this->entity->get("NOMOR")));
			if(count($cek) > 0){
				$data['ID'] = $cek[0]['ID'];
				$this->entity->exchangeArray($data);
				$this->table->update($this->entity->getArrayCopy(), array("PENANDA" => $this->entity->get("PENANDA"), "NOMOR"=>$this->entity->get("NOMOR")));
				$id = $cek[0]['ID'];
			} else {
				$this->table->insert($this->entity->getArrayCopy());
            	$id = $this->table->getLastInsertValue();
			}
			
		} else {
			$id = $this->entity->get("ID");
			$this->table->update($this->entity->getArrayCopy(), array("ID" => $id));
		}
		
		if($loaded) return $this->load(array("ID" => $id));
		return $id;
	}
	
	public function kosongkan($id) {
		$this->table->update(array("STATUS" => 0), array("PENANDA" => $id));
	}
}