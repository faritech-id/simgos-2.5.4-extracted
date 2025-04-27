<?php
namespace Pendaftaran\V1\Rest\KartuIdentitasPengantarPasien;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService
{
    public function __construct() {
		$this->config["entityName"] = "Pendaftaran\\V1\\Rest\\KartuIdentitasPengantarPasien\\KartuIdentitasPengantarPasienEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("kartu_identitas_pengantar_pasien", "pendaftaran"));
		$this->entity = new KartuIdentitasPengantarPasienEntity();
    }
}