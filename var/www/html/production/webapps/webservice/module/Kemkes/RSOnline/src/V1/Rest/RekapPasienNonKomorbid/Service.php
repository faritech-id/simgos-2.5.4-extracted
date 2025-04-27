<?php
namespace Kemkes\RSOnline\V1\Rest\RekapPasienNonKomorbid;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService {
	protected $writeLog = true;
	
	public function __construct($includeReferences = true, $references = []) {
        $this->config["entityName"] = "Kemkes\\RSOnline\\V1\\Rest\\RekapPasienNonKomorbid\\RekapPasienNonKomorbidEntity";
		$this->config["entityId"] = "id";
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("rekap_pasien_nonkomorbid", "kemkes-rsonline"));
		$this->entity = new RekapPasienNonKomorbidEntity();
	}	
}