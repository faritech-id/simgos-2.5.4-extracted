<?php
namespace Pendaftaran\V1\Rest\PerubahanTanggalKunjungan;

use DBService\DatabaseService;
use DBService\Service as DBService;
use DBService\System;
use Laminas\Db\Sql\Select;
use Laminas\Db\Sql\TableIdentifier;

class Service extends DBService
{	
    public function __construct() {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("perubahan_tanggal_kunjungan", "pendaftaran"));
		$this->entity = new PerubahanTanggalKunjunganEntity();
    }
        
	public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;		
		$this->entity->exchangeArray($data);
		$id = is_numeric($this->entity->get('ID')) ? $this->entity->get('ID') : 0;
		
		if(!isset($data["TANGGAL"])) $this->entity->set("TANGGAL", new \Laminas\Db\Sql\Expression('NOW()'));
		
		if($id > 0) {
			$this->table->update($this->entity->getArrayCopy(), array("ID" => $id));
		} else {			
			$this->table->insert($this->entity->getArrayCopy());
			$id = $this->table->getLastInsertValue();
		}
		
		return $this->load(array('ID' => $id));
	}
}