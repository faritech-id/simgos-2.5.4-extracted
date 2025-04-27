<?php
namespace Aplikasi\V1\Rest\InfoTeks;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;

use General\V1\Rest\Referensi\ReferensiService;

class InfoTeksService extends Service
{	
	private $referensi;

	protected $references = [
		'Referensi' => true
	];

    public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "Aplikasi\\V1\\Rest\\InfoTeks\\InfoTeksEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("info_teks", "aplikasi"));
		$this->entity = new InfoTeksEntity();

		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {
			if($this->references['Referensi']) $this->referensi = new ReferensiService();
		}
	}

	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		
		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['Referensi']) {
					$kelas = $this->referensi->load(['JENIS' => 150, 'ID' => $entity['JENIS']]);
					if(count($kelas) > 0) $entity['REFERENSI']['JENIS'] = $kelas[0];
				}
			}
		}
		
		return $data;
	}
}
