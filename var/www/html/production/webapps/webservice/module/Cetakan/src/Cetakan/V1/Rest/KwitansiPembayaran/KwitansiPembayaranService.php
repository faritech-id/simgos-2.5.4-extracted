<?php
namespace Cetakan\V1\Rest\KwitansiPembayaran;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\generator\Generator;
use Zend\json\Json;
use DBService\System;
use DBService\Service;

class KwitansiPembayaranService extends Service
{
    public function __construct() {
		$this->config["entityName"] = "Cetakan\\V1\\Rest\\KwitansiPembayaran\\KwitansiPembayaranEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("kwitansi_pembayaran", "cetakan"));
		$this->entity = new KwitansiPembayaranEntity();
    }

	protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
		if(empty($data["TANGGAL"])) $entity->set("TANGGAL", new \Laminas\Db\Sql\Expression('NOW()'));
		if($isCreated) {
			if($this->resource) {
				if($this->resource->getPropertyConfig(55) == "TRUE") $entity->set("NOMOR", $this->generateNomor());
			}
		}
	}

	public function generateNomor() {
        $adapter = $this->table->getAdapter();
		$conn = $adapter->getDriver()->getConnection();
	    $result = $conn->execute("SELECT generator.generateNoKuitansi(DATE(NOW())) NOMOR");
        $data = $result->current();
        return $data["NOMOR"];
    }
}