<?php
namespace LISService\V1\Rest\MappingHasil;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;

use LISService\V1\Rest\Parameter\Service as ParameterService;
use General\V1\Rest\ParameterTindakanLab\ParameterTindakanLabService;
use General\V1\Rest\Tindakan\TindakanService;

class Service extends DBService {
	private $parameterLis;
	private $parameterHis;
	private $pemeriksaan;
	protected $limit = 5000;

	protected $references = [
		"ParameterLis" => true,
		"ParameterHis" => true,
		"Pemeriksaan" => true
	];

	public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "LISService\\V1\\Rest\\MappingHasil\\MappingHasilEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("mapping_hasil", "lis"));
		$this->entity = new MappingHasilEntity();

		if($includeReferences) {
			if($this->references['ParameterLis']) $this->parameterLis = new ParameterService();
			if($this->references['ParameterHis']) $this->parameterHis = new ParameterTindakanLabService();
			if($this->references['Pemeriksaan']) $this->pemeriksaan = new TindakanService();
		}
	}

	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);

		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['ParameterLis']) {
					$parameter = $this->parameterLis->load(['VENDOR_ID' => $entity['VENDOR_LIS'], "KODE" => $entity["LIS_KODE_TEST"]]);
					if(count($parameter) > 0) $entity['REFERENSI']['PARAMETER_LIS'] = $parameter[0];
				}
				if($this->references['ParameterLis']) {
					$parameter = $this->parameterHis->load(['ID' => $entity['PARAMETER_TINDAKAN_LAB'], "TINDAKAN" => $entity["HIS_KODE_TEST"]]);
					if(count($parameter) > 0) $entity['REFERENSI']['PARAMETER_HIS'] = $parameter[0];
				}
				if($this->references['Pemeriksaan']) {
					$pemeriksaan = $this->pemeriksaan->load(['ID' => $entity["HIS_KODE_TEST"]]);
					if(count($pemeriksaan) > 0) $entity['REFERENSI']['PEMERIKSAAN'] = $pemeriksaan[0];
				}
			}
		}
		
		return $data;
	}
}