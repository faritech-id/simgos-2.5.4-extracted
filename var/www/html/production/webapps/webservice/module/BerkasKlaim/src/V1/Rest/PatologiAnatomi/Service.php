<?php
namespace BerkasKlaim\V1\Rest\PatologiAnatomi;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use DBService\generator\Generator;
use BerkasKlaim\V1\Rest\PatologiAnatomiDetil\Service as PatologiAnatomiDetilService;

class Service extends DBService
{
	private $PatologiAnatomiDetil;
	
    public function __construct() {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("patologi_anatomi", "berkas_klaim"));
		$this->entity = new PatologiAnatomiEntity();
		
		$this->PatologiAnatomiDetil = new PatologiAnatomiDetilService();
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
		
		$this->SimpanPatologiAnatomi($data, $id);
		
		return array(
			'success' => true
		);
	}
	
	private function SimpanPatologiAnatomi($data, $id) {
		if(isset($data['PATOLOGI_ANATOMI'])) {
			
			foreach($data['PATOLOGI_ANATOMI'] as $dtl) {
				$dtl['PATOLOGI_ANATOMI'] = $id;
				$this->PatologiAnatomiDetil->simpan($dtl);
			}
		}
	}
}
