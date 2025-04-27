<?php
namespace MedicalRecord\V1\Rest\RekonsiliasiTransfer;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use DBService\generator\Generator;

use Pendaftaran\V1\Rest\Kunjungan\KunjunganService;
use MedicalRecord\V1\Rest\RekonsiliasiTransferDetil\Service as RekonsiliasiTransferDetilService;

class Service extends DBService
{
	private $RekonsiliasiTransferDetil;
	private $Kunjungan;
	
    public function __construct() {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("rekonsiliasi_transfer", "medicalrecord"));
		$this->entity = new RekonsiliasiTransferEntity();
		
		$this->RekonsiliasiTransferDetil = new RekonsiliasiTransferDetilService();
		$this->Kunjungan = new KunjunganService();
    }
	
	public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;
		$this->entity->exchangeArray($data);
		$id = is_numeric($this->entity->get('ID')) ? $this->entity->get('ID') : 0;
		$penerima = $this->entity->get('PENERIMA');
		if($id == 0) {
			/* $nomor = Generator::generateNoPenerimaanLinen($penerima);
			$this->entity->set('NOMOR', $nomor); */
			$this->table->insert($this->entity->getArrayCopy());
			$id = $this->table->getLastInsertValue();
		} else {
			$this->table->update($this->entity->getArrayCopy(), array("ID" => $id));
		}
		
		$this->SimpanRekonsiliasiTransfer($data, $id);
		
		return array(
			'success' => true
		);
	}
	
	private function SimpanRekonsiliasiTransfer($data, $id) {
		if(isset($data['REKONSILIASI_TRANSFER'])) {
			
			foreach($data['REKONSILIASI_TRANSFER'] as $dtl) {
				$dtl['REKONSILIASI_TRANSFER'] = $id;
				$this->RekonsiliasiTransferDetil->simpan($dtl);
			}
		}
	}
	
	public function load($params = array(), $columns = array('*'), $orders = array()) {
		$data = parent::load($params, $columns, $orders);
		foreach($data as &$entity) {	
			$Kunjungan = $this->Kunjungan->load(array('NOMOR' => $entity['KUNJUNGAN']));
			if(count($Kunjungan) > 0) $entity['REFERENSI']['KUNJUNGAN'] = $Kunjungan[0];
		}	
		return $data;
	}
	/* 
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
			
			if(isset($params['PENERIMA_GROUP_ASAL'])) if(!System::isNull($params, 'PENERIMA_GROUP_ASAL')){
				$select->where("(PENERIMA = '".$params['PENERIMA_GROUP_ASAL']."')");
				$select->group("ASAL");
				unset($params['PENERIMA_GROUP_ASAL']);
			}
			
			$select->where($params);
			
			$select->order($orders);
		})->toArray();
	} */
}
