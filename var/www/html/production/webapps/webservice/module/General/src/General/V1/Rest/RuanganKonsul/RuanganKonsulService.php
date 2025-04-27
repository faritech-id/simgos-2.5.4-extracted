<?php
namespace General\V1\Rest\RuanganKonsul;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;
use Laminas\Db\Sql\Select;
use DBService\System;

use General\V1\Rest\Ruangan\RuanganService;

class RuanganKonsulService extends Service
{   
	private $ruanganasal;
	private $ruangantujuan;
	
	public function __construct() {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("ruangan_konsul", "master"));
		$this->entity = new RuanganKonsulEntity();
		$this->limit = 500;
		
		$this->ruanganasal = new RuanganService();
		$this->ruangantujuan = new RuanganService();
    }

	public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;
		$this->entity->exchangeArray($data);
		$ruangan = $this->entity->get('RUANGAN');
		$konsul = $this->entity->get('KONSUL');
		$cek = $this->table->select(array("RUANGAN" => $ruangan, "KONSUL" => $konsul))->toArray();
		if(count($cek) > 0) {
			$this->table->update($this->entity->getArrayCopy(), array('RUANGAN' => $ruangan, "KONSUL" => $konsul));
		} else {
			$this->table->insert($this->entity->getArrayCopy());
		}
		
		return array(
			'success' => true
		);
	}
	
	public function load($params = array(), $columns = array('*'), $orders = array()) {
		$data = parent::load($params, $columns, $orders);
		
		foreach($data as &$entity) {
			$ruanganasal = $this->ruanganasal->load(array('ID' => $entity['RUANGAN']));
			if(count($ruanganasal) > 0) $entity['REFERENSI']['RUANGAN'] = $ruanganasal[0];
			$results = $this->parseReferensi($entity, "konsul");
			if(count($results) > 0) $entity["REFERENSI"]["KONSUL"] = $results;
		}
		
		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'STATUS')) {
			$status = $params['STATUS'];
			$params['ruangan_konsul.STATUS'] = $status;
			unset($params['STATUS']);
		}

		$fields = $this->ruangantujuan->getEntity()->getFieldWithAlias("konsul");
		$fields["DESKRIPSI"] = "DESKRIPSI";
		$select->join(
			["konsul" => new TableIdentifier('ruangan', 'master')],
			new \Laminas\Db\Sql\Predicate\Expression("konsul.ID = ruangan_konsul.KONSUL"),
			$fields
		);
	}
}