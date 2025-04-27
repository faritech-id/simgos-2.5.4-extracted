<?php
namespace LISService\vanslab\dbservice\order_lab;

use DBService\DatabaseService;
use Laminas\Db\Sql\Select;
use DBService\Service as DBService;

class Service extends DBService
{	
    public function __construct() {
		$this->config["entityName"] = "LISService\\vanslab\\dbservice\\order_lab\\Entity";
		$this->config["autoIncrement"] = false;
        $this->table = DatabaseService::get('Vanslab')->get('order_lab');
		$this->entity = new Entity();
    }

	public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;
		$this->entity->exchangeArray($data);
		$params = [
			"no_registrasi" => $this->entity->get('no_registrasi'),
			"test" => $this->entity->get('test')
		];
		$rows = $this->table->select($params)->toArray();
		if(count($rows) > 0){
			$this->table->update($this->entity->getArrayCopy(), $params);
		} else {
			$this->table->insert($this->entity->getArrayCopy());
		}
		
		return true;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		$select->join(
			['o' => 'order_lab'], 
			"o.no_registrasi = hasil_lab.no_registrasi AND hasil_lab.kode_test_his LIKE CONCAT(o.test, '%')", 
			["test"]
		);
	}
}