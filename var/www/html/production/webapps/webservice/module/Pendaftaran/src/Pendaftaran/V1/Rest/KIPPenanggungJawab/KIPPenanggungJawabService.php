<?php
namespace Pendaftaran\V1\Rest\KIPPenanggungJawab;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;

class KIPPenanggungJawabService extends Service
{
    public function __construct() {
		$this->config["entityName"] = "Pendaftaran\\V1\\Rest\\KIPPenanggungJawab\\KIPPenanggungJawabEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("kartu_identitas_penanggung_jawab", "pendaftaran"));
		$this->entity = new KIPPenanggungJawabEntity();
    }
}