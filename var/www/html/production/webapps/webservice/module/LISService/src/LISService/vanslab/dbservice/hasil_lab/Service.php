<?php
namespace LISService\vanslab\dbservice\hasil_lab;

use DBService\DatabaseService;
use Laminas\Db\Sql\Select;
use DBService\Service as DBService;

class Service extends DBService
{	
	private $fieldStatusResult = "status";

    public function __construct() {		
        $this->table = DatabaseService::get('Vanslab')->get('hasil_lab');
		$this->entity = new Entity();
		$this->limit = 25;
    }

	public function setFieldStatusResult($fieldName) {
		$this->fieldStatusResult = $fieldName;
		$entity = $this->getEntity();
		$entity->addField($fieldName, 1);
	}
		
	public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;
		$this->entity-> exchangeArray($data);
		$field = $this->fieldStatusResult;
		unset($data[$field]);
		$rows = $this->load($data);
		if(count($rows) > 0){
			$this->table->update($this->entity->getArrayCopy(), $data);
		} else {
			//$this->table->insert($this->entity->getArrayCopy());
		}
		
		return true;
	}
}