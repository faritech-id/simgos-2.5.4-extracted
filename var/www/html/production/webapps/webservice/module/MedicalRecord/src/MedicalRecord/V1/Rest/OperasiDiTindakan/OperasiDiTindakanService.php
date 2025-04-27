<?php
namespace MedicalRecord\V1\Rest\OperasiDiTindakan;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;
use Laminas\Db\Sql\Select;
use Laminas\Db\Sql\Expression;
use DBService\System;

class OperasiDitindakanService extends Service
{
    public function __construct() {
        $this->config["entityName"] = "MedicalRecord\\V1\\Rest\\OperasiDiTindakan\\OperasiDiTindakanEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("operasi_di_tindakan", "medicalrecord"));
        $this->entity = new OperasiDiTindakanEntity();
    }
}