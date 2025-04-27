<?php
namespace MedicalRecord\V1\Rest\PenilaianBallanceCairanDetail;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;

class Service extends DBService
{
    public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\PenilaianBallanceCairanDetail\\PenilaianBallanceCairanDetailEntity";
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("penilaian_ballance_cairan_detail", "medicalrecord"));
		$this->entity = new PenilaianBallanceCairanDetailEntity();
    }	
}
