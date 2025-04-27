<?php
namespace MedicalRecord\V1\Rest\PenandaGambar;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use MedicalRecord\V1\Rest\PenandaGambarDetail\Service as PenandaDetailService;
use General\V1\Rest\TemplateAnatomi\Service as TemplateAnatomiService;

class Service extends DBService {
	
    private $detail;
	private $template;

	protected $references = array(
		'PenandaDetail' => true,
		'TemplateAnatomi' => true
	);

	
	public function __construct($includeReferences = true, $references = array()) {
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\PenandaGambar\\PenandaGambarEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("penanda_gambar", "medicalrecord"));
		$this->entity = new PenandaGambarEntity();
		
		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {
			if($this->references['PenandaDetail']) $this->detail = new PenandaDetailService();
			if($this->references['TemplateAnatomi']) $this->template = new TemplateAnatomiService();
		}
	}
	
    public function simpan($data, $isCreated = false, $loaded = true) {
		$data = is_array($data) ? $data : (array) $data;
		$this->entity = new PenandaGambarEntity();
		$this->entity->exchangeArray($data);
		
		if($isCreated) {
			$this->table->insert($this->entity->getArrayCopy());
            $id = $this->table->getLastInsertValue();
		} else {
			$id = $this->entity->get("ID");
			$this->table->update($this->entity->getArrayCopy(), ["ID" => $id]);
		}
		
		$this->simpanPenandaDetail($data, $id);

		if($loaded) return $this->load(["ID" => $id]);
		return $id;
	}

    private function simpanPenandaDetail($data, $id) {
		if(isset($data['PENANDA_DETAIL'])) {
			$this->detail->kosongkan($id);
			foreach($data['PENANDA_DETAIL'] as $tgs) {
				$tgs['PENANDA'] = $id;
				$this->detail->simpan($tgs, true);
			}
		}
	}

	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);

		if($this->includeReferences) {
			foreach($data as &$entity) {
								
				if($this->references['TemplateAnatomi']) {
					$template = $this->template->load(array('ID' => $entity['TEMPLATE']));
					if(count($template) > 0) $entity['REFERENSI']['TEMPLATE'] = $template[0];
				}
				
			}
		}
		
		return $data;
	}
	
	
}