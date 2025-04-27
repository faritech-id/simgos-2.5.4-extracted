<?php
namespace MedicalRecord\V1\Rest\JenisIndikatorKeperawatan;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;

class Service extends DBService {
	
	public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\JenisIndikatorKeperawatan\\JenisIndikatorKeperawatanEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("jenis_indikator_keperawatan", "medicalrecord"));
		$this->entity = new JenisIndikatorKeperawatanEntity();
	}
}