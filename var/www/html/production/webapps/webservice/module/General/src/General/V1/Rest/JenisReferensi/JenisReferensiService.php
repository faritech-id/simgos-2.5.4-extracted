<?php
namespace General\V1\Rest\JenisReferensi;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;

class JenisReferensiService extends Service
{
	protected $limit = 1000;
	
    public function __construct() {
        $this->config["entityName"] = "General\\V1\\Rest\\JenisReferensi\\JenisReferensiEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("jenis_referensi", "master"));
        $this->entity = new JenisReferensiEntity();
    }
}