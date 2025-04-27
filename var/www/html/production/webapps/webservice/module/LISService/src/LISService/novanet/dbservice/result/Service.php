<?php
namespace LISService\novanet\dbservice\result;

use DBService\DatabaseService;
use Laminas\Db\Sql\Select;
use DBService\Service as DBService;

class Service extends DBService
{	
	private $fieldStatusResult = "Status";

    public function __construct() {		
        $this->table = DatabaseService::get('Novanet')->get('Result');
		$this->entity = new Entity();
		$this->limit = 5;
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

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		$select->join(['o' => 'Orders'], "o.ID = Result._OID", ["InstrID"]);
		$select->join(['p' => 'Patient'], "p.ID = Result._PID", ["Lab_PatientID"]);
		$select->join(['d' => 'POCTDeviceStatus'], "d.MsgID = o.MsgID", ["Location", "DeviceID"]);
	}
}