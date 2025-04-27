<?php
namespace BerkasKlaim\V1\Rest\LabKlinik;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use DBService\generator\Generator;
use BerkasKlaim\V1\Rest\LabKlinikDetil\Service as LabKlinikDetilService;

class Service extends DBService
{
	private $LabKlinikDetil;
	
    public function __construct() {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("lab_klinik", "berkas_klaim"));
		$this->entity = new LabKlinikEntity();
		
		$this->LabKlinikDetil = new LabKlinikDetilService();
    }
	
	public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;
		$this->entity->exchangeArray($data);
		$id = is_numeric($this->entity->get('ID')) ? $this->entity->get('ID') : 0;
		if($id == 0) {
			$this->table->insert($this->entity->getArrayCopy());
			$id = $this->table->getLastInsertValue();
		} else {
			$this->table->update($this->entity->getArrayCopy(), array("ID" => $id));
		}
		
		$this->SimpanLabKlinik($data, $id);
		
		return array(
			'success' => true
		);
	}
	
	private function SimpanLabKlinik($data, $id) {
		if(isset($data['LAB_KLINIK'])) {
			
			foreach($data['LAB_KLINIK'] as $dtl) {
				$dtl['LAB_KLINIK'] = $id;
				$this->LabKlinikDetil->simpan($dtl);
			}
		}
	}
}
