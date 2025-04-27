<?php
namespace BerkasKlaim\V1\Rest\ObatFarmasi;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use DBService\generator\Generator;

use Pendaftaran\V1\Rest\Pendaftaran\PendaftaranService;
use BerkasKlaim\V1\Rest\ObatFarmasiDetil\Service as ObatFarmasiDetilService;

class Service extends DBService
{
	private $ObatFarmasiDetil;
	private $Pendaftaran;
	
    public function __construct() {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("obat_farmasi", "berkas_klaim"));
		$this->entity = new ObatFarmasiEntity();
		
		$this->ObatFarmasiDetil = new ObatFarmasiDetilService();
		$this->Pendaftaran = new PendaftaranService();
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
		
		$this->SimpanObatFarmasi($data, $id);
		
		return array(
			'success' => true
		);
	}
	
	private function SimpanObatFarmasi($data, $id) {
		if(isset($data['OBAT_FARMASI'])) {
			
			foreach($data['OBAT_FARMASI'] as $dtl) {
				$dtl['OBAT_FARMASI'] = $id;
				$this->ObatFarmasiDetil->simpan($dtl);
			}
		}
	}
	
	public function load($params = array(), $columns = array('*'), $orders = array()) {
		$data = parent::load($params, $columns, $orders);
		foreach($data as &$entity) {	
			$Pendaftaran = $this->Pendaftaran->load(array('NOMOR' => $entity['PENDAFTARAN']));
			if(count($Pendaftaran) > 0) $entity['REFERENSI']['PENDAFTARAN'] = $Pendaftaran[0];
		}	
		return $data;
	}
}
