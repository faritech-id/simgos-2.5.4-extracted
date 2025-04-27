<?php
namespace Layanan\V1\Rest\O2;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;
use Laminas\Db\Sql\Select;

use Laminas\Db\Sql\Expression;
use DBService\System;
use DBService\generator\Generator;
use General\V1\Rest\Referensi\ReferensiService;

class O2Service extends Service
{
	private $referensi;
	protected $references = [
		'Referensi' => true		
	];
	
    public function __construct($includeReferences = true, $references = array())  {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("o2", "layanan"));
		$this->entity = new O2Entity();
		$this->referensi = new ReferensiService();
    }
        
	public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;
		$this->entity->exchangeArray($data);
		
		$id = is_numeric($this->entity->get('ID')) ? $this->entity->get('ID') : false;
		
		if($id) {
			$_data = $this->entity->getArrayCopy();
			$this->table->update($_data, array("ID" => $id));
		} else {
			$id = Generator::generateIdO2();
			$this->entity->set('ID', $id);
		
			$_data = $this->entity->getArrayCopy();
			$this->table->insert($_data);
		}
		
		return $this->load(array('o2.ID' => $id));
	}

	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		foreach($data as &$entity) {		
			$referensi = $this->referensi->load(['JENIS' => 220,'ID' => $entity['JENIS']]);
			if(count($referensi) > 0) $entity['REFERENSI']['JENIS'] = $referensi[0];
		}
		
		return $data;
	}
	
	
}