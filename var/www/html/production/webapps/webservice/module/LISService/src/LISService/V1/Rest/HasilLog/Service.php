<?php
namespace LISService\V1\Rest\HasilLog;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;

class Service extends DBService {
	
	public function __construct($includeReferences = true, $references = array()) {
		$this->config["entityName"] = "LISService\\V1\\Rest\\HasilLog\\HasilLogEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("hasil_log", "lis"));
		$this->entity = new HasilLogEntity();
	}
	
	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		$select->join(['k'=>new TableIdentifier('kunjungan', 'pendaftaran')], 'k.NOMOR = hasil_log.HIS_NO_LAB', [], Select::JOIN_LEFT);
		$select->join(['p'=>new TableIdentifier('pendaftaran', 'pendaftaran')], 'p.NOMOR = k.NOPEN', [], Select::JOIN_LEFT);
		$select->join(['ps'=>new TableIdentifier('pasien', 'master')], 'ps.NORM = p.NORM', ['PASIEN_NORM' => 'NORM', 'PASIEN_NAMA' => 'NAMA'], Select::JOIN_LEFT);
		$select->join(['t'=>new TableIdentifier('tindakan', 'master')], 't.ID = hasil_log.HIS_KODE_TEST', ['PEMERIKSAAN' => 'NAMA'], Select::JOIN_LEFT);
		$select->join(['u'=>new TableIdentifier('pengguna', 'aplikasi')], 'u.ID = hasil_log.LIS_USER', ['PETUGAS_NAMA' => 'NAMA'], Select::JOIN_LEFT);
		$select->join(['v'=>new TableIdentifier('vendor_lis', 'lis')], 'v.ID = hasil_log.VENDOR_LIS', ['VENDOR_NAMA' => 'NAMA'], Select::JOIN_LEFT);
		$select->join(['s'=>new TableIdentifier('status_hasil', 'lis')], 's.ID = hasil_log.STATUS', ['STATUS_DESKRIPSI' => 'DESKRIPSI'], Select::JOIN_LEFT);

		if(!System::isNull($params, 'ID')) {
			$id = $params['ID'];
			$params['hasil_log.ID'] = $id;
			unset($params['ID']);
		}

		if(!System::isNull($params, 'NORM')) {
			$norm = $params['NORM'];
			$params['p.NORM'] = $norm;
			unset($params['NORM']);
		}
		if(!System::isNull($params, 'NAMA')) {
			$params[] = new \Zend\Db\Sql\Predicate\Expression("ps.NAMA LIKE '".$params["NAMA"]."%'");
			unset($params['NAMA']);
		}
		if(!System::isNull($params, 'NOPEN')) {
			$nomor = $params['NOPEN'];
			$params['p.NOMOR'] = $nomor;
			unset($params['NOPEN']);
		}
	}
}