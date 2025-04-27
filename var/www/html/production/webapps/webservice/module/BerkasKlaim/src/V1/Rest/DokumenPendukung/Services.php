<?php
namespace BerkasKlaim\V1\Rest\DokumenPendukung;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service AS DBService;

class Services extends DBService
{	
	public function __construct() {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("dokumen_pendukung", "berkas_klaim"));
        
		$this->entity = new DokumenPendukungEntity();
    }
	
	public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;
		$cek = is_numeric($data['ID']) ? $data['ID'] : 0;
		if($cek == 0) {
			$this->entity->exchangeArray($data);
			$this->table->insert($this->entity->getArrayCopy());
			
		} else {
			$this->entity->exchangeArray($data);
			$this->table->update($this->entity->getArrayCopy(), array("ID" => $this->entity->get('ID')));
		}
		
		return array(
			'success' => true
		);
	}
}