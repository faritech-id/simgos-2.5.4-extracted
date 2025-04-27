<?php
namespace General\V1\Rest\RuanganFarmasi;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;
use Laminas\Db\Sql\Select;
use DBService\System;

use General\V1\Rest\Ruangan\RuanganService;

class RuanganFarmasiService extends Service
{   
	private $ruanganasal;
	private $ruangantujuan;
	
	public function __construct() {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("ruangan_farmasi", "master"));
		$this->entity = new RuanganFarmasiEntity();
		$this->limit = 500;
		
		$this->ruanganasal = new RuanganService();
		$this->ruangantujuan = new RuanganService();
    }
    

	public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;
		$this->entity->exchangeArray($data);
		$ruangan = $this->entity->get('RUANGAN');
		$farmasi = $this->entity->get('FARMASI');
		$cek = $this->table->select(array("RUANGAN" => $ruangan, "FARMASI" => $farmasi))->toArray();
		if(count($cek) > 0) {
			$this->table->update($this->entity->getArrayCopy(), array('RUANGAN' => $ruangan, "FARMASI" => $farmasi));
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
			$results = $this->parseReferensi($entity, "farmasi");
			if(count($results) > 0) $entity["REFERENSI"]["FARMASI"] = $results;
		}
		
		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'STATUS')) {
			$status = $params['STATUS'];
			$params['ruangan_farmasi.STATUS'] = $status;
			unset($params['STATUS']);
		}

		$fields = $this->ruangantujuan->getEntity()->getFieldWithAlias("farmasi");
		$fields["DESKRIPSI"] = "DESKRIPSI";
		$select->join(
			["farmasi" => new TableIdentifier('ruangan', 'master')],
			new \Laminas\Db\Sql\Predicate\Expression("farmasi.ID = ruangan_farmasi.FARMASI"),
			$fields
		);
	}
}