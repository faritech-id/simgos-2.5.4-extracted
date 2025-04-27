<?php
namespace BerkasKlaim\V1\Rest\ObatFarmasiDetil;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use DBService\generator\Generator;

use Pendaftaran\V1\Rest\Kunjungan\KunjunganService;

class Service extends DBService
{
	private $Kunjungan;
	
    public function __construct() {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("obat_farmasi_detil", "berkas_klaim"));
		$this->entity = new ObatFarmasiDetilEntity();
		$this->Kunjungan = new KunjunganService();
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
		
		return array(
			'success' => true
		);
	}
	
	public function load($params = array(), $columns = array('*'), $orders = array()) {
		$data = parent::load($params, $columns, $orders);
		foreach($data as &$entity) {	
			$Kunjungan = $this->Kunjungan->load(array('NOMOR' => $entity['KUNJUNGAN']));
			if(count($Kunjungan) > 0) $entity['REFERENSI']['KUNJUNGAN'] = $Kunjungan[0];
		}	
		return $data;
	}
	
	protected function query($columns, $params, $isCount = false, $orders = array()) {		
		$params = is_array($params) ? $params : (array) $params;		

		return $this->table->select(function(Select $select) use ($isCount, $params, $columns, $orders) {
			if($isCount) $select->columns(array('rows' => new \Laminas\Db\Sql\Expression('COUNT(1)')));
			else if(!$isCount) $select->columns($columns);			
			if(!System::isNull($params, 'start') && !System::isNull($params, 'limit')) {	
				if(!$isCount) $select->offset((int) $params['start'])->limit((int) $params['limit']);
				unset($params['start']);
				unset($params['limit']);
				
			} else $select->offset(0)->limit($this->limit);
			
			if(isset($params['STATUS'])) if(!System::isNull($params, 'STATUS')){
				$select->where("obat_farmasi_detil.STATUS IN (1, 2)");
				unset($params['STATUS']);
			}
			
			$select->where($params);
			
			$select->order($orders);
		})->toArray();
	}
}
