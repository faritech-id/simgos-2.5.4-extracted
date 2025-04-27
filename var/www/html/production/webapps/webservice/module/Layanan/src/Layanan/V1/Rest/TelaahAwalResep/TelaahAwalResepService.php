<?php
namespace Layanan\V1\Rest\TelaahAwalResep;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;
class TelaahAwalResepService extends Service
{
	private $barang;

    public function __construct() {
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("telaah_awal_resep", "layanan"));
		$this->entity = new TelaahAwalResepEntity();
		
    }

	public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;		
		$this->entity->exchangeArray($data);
		$telaah = $this->load(array('RESEP' => $this->entity->get('RESEP'), 'REF_TELAAH' => $this->entity->get('REF_TELAAH'),'JENIS' => $this->entity->get('JENIS')));
		if(count($telaah) > 0) {
			$this->table->update($this->entity->getArrayCopy(), ['ID' => $telaah[0]['ID']]);
		} else {
			$this->table->insert($this->entity->getArrayCopy());
		}
		
		return array(
			'success' => true
		);
	}
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		foreach($data as &$entity) {
            
        }
				
		return $data;
	}

    protected function queryCallback(Select &$select, &$params, $columns, $orders) {
        if(!System::isNull($params, 'RESEP')) { 
			$select->where(["RESEP" => $params['RESEP']]);
			unset($params['RESEP']);
		}
        if(!System::isNull($params, 'JENIS')) { 
			$select->where(["JENIS" => $params['JENIS']]);
			unset($params['JENIS']);
		}
        if(!System::isNull($params, 'STATUS')) { 
			$select->where(["STATUS" => $params['STATUS']]);
			unset($params['STATUS']);
		}
	}
}
