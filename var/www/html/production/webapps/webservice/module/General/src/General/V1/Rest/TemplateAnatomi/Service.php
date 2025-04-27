<?php
namespace General\V1\Rest\TemplateAnatomi;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use General\V1\Rest\Referensi\ReferensiService;

class Service extends DBService {
	private $smf;

	protected $references = array(
		'SMF' => true
	);
	
	public function __construct($includeReferences = true, $references = array()) {
		$this->config["entityName"] = "General\\V1\\Rest\\TemplateAnatomi\\TemplateAnatomiEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("template_anatomi", "master"));
		$this->entity = new TemplateAnatomiEntity();
		
		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {
			if($this->references['SMF']) $this->smf = new ReferensiService();
		}
	}
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		
		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['SMF']) {
					if(isset($entity['KSM'])) {
						$smf = $this->smf->load(['JENIS' => 26,'ID' => $entity['KSM']]);
						if(count($smf) > 0) $entity['REFERENSI']['KSM'] = $smf[0];
					}					
				}
			}
		}
		
		return $data;
	}


}