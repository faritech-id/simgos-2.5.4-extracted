<?php
namespace Kemkes\V2\Rpc\Penyakit10Besar;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;

use General\V1\Rest\Referensi\ReferensiService;
class Service extends DBService
{
    private $referensi;

    protected $references = array(
		'Referensi' => true
    );
    
    public function __construct($includeReferences = true, $references = array()) {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("statistik_10_besar_penyakit", "informasi"));
        $this->entity = new Entity();

        $this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {
			if($this->references['Referensi']) $this->referensi = new ReferensiService();
		}
    }
	
    public function simpan($data) {
        $data = is_array($data) ? $data : (array) $data;
        $this->entity = new Entity();
        $this->entity->exchangeArray($data);
        
        $params = [
            "TAHUN" => $this->entity->get("TAHUN"),
            "BULAN" => $this->entity->get("BULAN"),
            "JENIS_PELAYANAN" => $this->entity->get("JENIS_PELAYANAN")
        ];
        $this->table->update($this->entity->getArrayCopy(), $params);
        
        return true;
    }

    public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		
		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['Referensi']) {
					$kelas = $this->referensi->load(['JENIS' => 83, 'ID' => $entity['BULAN']]);
					if(count($kelas) > 0) $entity['REFERENSI']['BULAN'] = $kelas[0];
				}
			}
		}
		
		return $data;
	}
}