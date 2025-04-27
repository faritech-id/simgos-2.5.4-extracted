<?php
namespace Layanan\V1\Rest\NilaiKritisLab;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as dbService;
use Layanan\V1\Rest\HasilLab\HasilLabService;

class Service extends dbService{
    private $hasillab;

    protected $references = [
        "HasilLab" => true
    ];

    public function __construct($includeReferences = true, $references = []){
        $this->config["entityName"] = "\\Layanan\\V1\\Rest\\NilaiKritisLab\\NilaiKritisLabEntity";
        $this->config["entityId"] = "ID";
        $this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("nilai_kritis_lab","layanan"));
        $this->entity = new NilaiKritisLabEntity();

        $this->setReferences($references);
		
		$this->includeReferences = $includeReferences;

		if($includeReferences) {
            if($this->references['HasilLab']) $this->hasillab = new HasilLabService();
        }
    }

    public function load($params = array(), $columns = array('*'), $orders = array()) {
		$data = parent::load($params, $columns, $orders);
        
		foreach($data as &$entity) {
            if($this->includeReferences){
                if($this->references['HasilLab']){
                    if(is_object($this->references['HasilLab'])) {
						$references = isset($this->references['HasilLab']->REFERENSI) ? (array) $this->references['HasilLab']->REFERENSI : [];
						$this->hasillab->setReferences($references, true);
						if(isset($this->references['HasilLab']->COLUMNS)) $this->hasillab->setColumns((array) $this->references['HasilLab']->COLUMNS);
					}
                    $hasillab = $this->hasillab->load(['ID' => $entity['HASIL_LAB']]);
                    if(count($hasillab) > 0) $entity['REFERENSI']['HASIL_LAB'] = $hasillab[0];
                }
            }
		}
        	
		return $data;
	}

    protected function queryCallback(Select &$select, &$params, $columns, $orders) {
        if(!System::isNull($params, 'STATUS')) {
			$params['nilai_kritis_lab.STATUS'] = $params['STATUS'];
			unset($params['STATUS']);
		}

		if(!System::isNull($params, 'QUERY')) {
			$select->join(
				["hr" => new TableIdentifier("hasil_lab", 'layanan')],
				"hr.ID = nilai_kritis_lab.HASIL_LAB",
				[],
				Select::JOIN_LEFT
			);

			$select->join(
				["tm" => new TableIdentifier("tindakan_medis", 'layanan')],
				"hr.TINDAKAN_MEDIS = tm.ID",
				[],
				Select::JOIN_LEFT
			);

			$select->join(
				["pk" => new TableIdentifier("kunjungan", 'pendaftaran')],
				"tm.KUNJUNGAN = pk.NOMOR",
				[],
				Select::JOIN_LEFT
			);

			$select->join(
				["pp" => new TableIdentifier("pendaftaran", 'pendaftaran')],
				"pk.NOPEN = pp.NOMOR",
				[],
				Select::JOIN_LEFT
			);
			$params['pp.NORM'] = $params['QUERY'];
			unset($params['QUERY']);
		}
	}
}
