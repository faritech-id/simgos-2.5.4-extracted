<?php
namespace BerkasKlaim\V1\Rest\Radiologi;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use DBService\generator\Generator;
use BerkasKlaim\V1\Rest\RadiologiDetil\Service as RadiologiDetilService;

class Service extends DBService
{
	private $RadiologiDetil;
    public function __construct() {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("radiologi", "berkas_klaim"));
		$this->entity = new RadiologiEntity();
		
		$this->RadiologiDetil = new RadiologiDetilService();
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
		
		$this->SimpanRadiologi($data, $id);
		
		return array(
			'success' => true
		);
	}
	
	private function SimpanRadiologi($data, $id) {
		if(isset($data['RADIOLOGI'])) {
			
			foreach($data['RADIOLOGI'] as $dtl) {
				$dtl['RADIOLOGI'] = $id;
				$this->RadiologiDetil->simpan($dtl);
			}
		}
	}
}
