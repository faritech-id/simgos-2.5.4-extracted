<?php
namespace General\V1\Rest\LockAksesPasien;
use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\System;
use DBService\Service as DBService;

class Service extends DBService
{
  public function __construct() {
    $this->config["entityName"] = "General\\V1\\Rest\\LockAksesPasien\\LockAksesPasienEntity";
    $this->config["entityId"] = "NORM";
    $this->config["autoIncrement"] = false;
    $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("lock_akses_pasien", "master"));
    $this->entity = new LockAksesPasienEntity();
  }

  protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
    $adapter = $this->getTable()->getAdapter();
    $sysdate = System::getSysDate($adapter, true, true);
    $entity["TANGGAL"] = $sysdate;
  }
}
