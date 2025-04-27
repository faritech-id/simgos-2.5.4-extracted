<?php
namespace MedicalRecord\V1\Rest\Operasi;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;
use Laminas\Db\Sql\Select;
use Laminas\Db\Sql\Expression;
use DBService\System;

use MedicalRecord\V1\Rest\OperasiDiTindakan\OperasiDiTindakanService;
use General\V1\Rest\Dokter\DokterService;

use Pendaftaran\V1\Rest\Kunjungan\KunjunganService;
use MedicalRecord\V1\Rest\PelaksanaOperasi\Service as PelaksanaService;

class OperasiService extends Service
{
	private $tindakan;
	private $dokter;
	private $pelaksana;
	
    public function __construct() {
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\Operasi\\OperasiEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("operasi", "medicalrecord"));
		$this->entity = new OperasiEntity();
		
		$this->tindakan = new OperasiDiTindakanService();
		$this->dokter = new DokterService();
		$this->kunjungan = new KunjunganService();
		$this->pelaksana = new PelaksanaService();
    }
        
	protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
		if($isCreated) $entity->set("DIBUAT_TANGGAL", new \Laminas\Db\Sql\Expression('NOW()'));
	}
	protected function onAfterSaveCallback($id, $data) {
		$this->simpanTindakan($data, $id);
		$this->simpanPelaksana($data, $id);
	}

	private function simpanTindakan($data, $id) {
		if(isset($data['TINDAKAN_MEDIS'])) {
			foreach($data['TINDAKAN_MEDIS'] as $td) {
				$td['OPERASI_ID'] = $id;
				$founds = $this->tindakan->load([
					"OPERASI_ID" => $id,
					"TINDAKAN_MEDIS" => $td["TINDAKAN_MEDIS"]
				]);
				$this->tindakan->simpanData($td, count($founds) == 0, false); 
			}
		}
	}

	private function simpanPelaksana($data, $id) {
		if(isset($data['PELAKSANA'])) {
			foreach($data['PELAKSANA'] as $p) {
				$p['OPERASI_ID'] = $id;
				$founds = $this->pelaksana->load([
					"OPERASI_ID" => $id,
					"JENIS" => $p["JENIS"],
					"PELAKSANA" => $p["PELAKSANA"]
				]);
				$p["STATUS"] = 1;
				if(count($founds) > 0) $p["ID"] = $founds[0]["ID"];
				$this->pelaksana->simpanData($p, count($founds) == 0, false); 
			}
		}
	}
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		foreach($data as &$entity) {
			$dokter = $this->dokter->load(['ID' => $entity['DOKTER']]);
			if(count($dokter) > 0) $entity['REFERENSI']['DOKTER'] = $dokter[0];
			$kunjungan = $this->kunjungan->load(['NOMOR' => $entity['KUNJUNGAN']]);
			if(count($kunjungan) > 0) $entity['REFERENSI']['KUNJUNGAN'] = $kunjungan[0];
		}
		
		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'TANGGAL')) {
			$tanggal = $params['TANGGAL'];
			$params['operasi.TANGGAL'] = $tanggal;
			unset($params['TANGGAL']);
		}
		
		if(!System::isNull($params, 'STATUS')) {
			$status = $params['STATUS'];
			$params['operasi.STATUS'] = $status;
			unset($params['STATUS']);
		}
		
		$select->join(
			['kjgn' => new TableIdentifier('kunjungan', 'pendaftaran')],
			'kjgn.NOMOR = operasi.KUNJUNGAN',
			['NOPEN']
		);
		
		$select->join(
			['pdftrn' => new TableIdentifier('pendaftaran', 'pendaftaran')],
			'pdftrn.NOMOR = kjgn.NOPEN',
			[]
		);
		
		if(isset($params['NAMA_OPERASI'])) {
			$select->where("(operasi.NAMA_OPERASI LIKE '%".$params['NAMA_OPERASI']."%')");
			unset($params['NAMA_OPERASI']);
		}
	}
}