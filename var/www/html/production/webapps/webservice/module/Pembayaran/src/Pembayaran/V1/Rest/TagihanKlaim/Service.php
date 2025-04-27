<?php
namespace Pembayaran\V1\Rest\TagihanKlaim;

use DBService\DatabaseService;
use Laminas\Db\Sql\Select;
use DBService\System;
use Zend\json\Json;
use DBService\Service as DBService;
use Laminas\Db\Sql\TableIdentifier;

use General\V1\Rest\Referensi\ReferensiService;
use General\V1\Rest\Pasien\PasienService;
use Pendaftaran\V1\Rest\TujuanPasien\TujuanPasienService;

class Service extends DBService
{
	private $pasien;
	private $referensi;
	private $tujuan;
	
	protected $references = [
		'Pasien' => true,
		'Tujuan' => true,
		'Penjamin' => true
	];
    
    public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "\\Pembayaran\\V1\\Rest\\TagihanKlaim\\TagihanKlaimEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("tagihan_klaim", "pembayaran"));
		$this->entity = new TagihanKlaimEntity();
		
		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {
			if($this->references['Pasien']) $this->pasien = new PasienService(false);
			if($this->references['Tujuan']) $this->tujuan = new TujuanPasienService(true, [
				'Pendaftaran' => false,
				'Ruangan' => json_decode(json_encode([
					"REFERENSI" => [
						"Referensi" => true
					]
				])),
				'Referensi' => false,
				'Dokter' => false,
				'AntrianRuangan' => false
			]);
		}

		$this->referensi = new ReferensiService();
    }
    
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);

		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['Pasien']) {
					$result = $this->pasien->load(['NORM' => $entity['NORM']], ["NORM", "NAMA", "GELAR_DEPAN", "GELAR_BELAKANG"]);
					if(count($result) > 0) $entity['REFERENSI']['PASIEN'] = $result[0];
				}

				if($this->references['Penjamin']) {
					$result = $this->referensi->load(['ID' => $entity['PENJAMIN'], 'JENIS' => 10]);
					if(count($result) > 0) $entity['REFERENSI']['PENJAMIN'] = $result[0];
				}

				if($this->references['Tujuan']) {
					$result = $this->tujuan->load(['NOPEN' => $entity['NOPEN']]);
					if(count($result) > 0) $entity['REFERENSI']['TUJUAN'] = $result[0];
				}

				$entity['REFERENSI']['JENIS'] = [
					"ID" => $entity['JENIS'],
					"DESKRIPSI" => ($entity['JENIS'] == 1 ? 'Non Piutang' : 'Piutang Perusahaan')
				];
			}
		}
		
		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(isset($params['TANGGAL_FINAL'])) if(!System::isNull($params, 'TANGGAL_FINAL')){
			$awal = $params['TANGGAL_FINAL']." 00:00:00";
			$akhir = $params['TANGGAL_FINAL']." 23:59:59";
			$select->where("(tagihan_klaim.TANGGAL_FINAL BETWEEN '$awal' AND '$akhir')");
			unset($params['TANGGAL_FINAL']);
		}

		if(isset($params['MASUK'])) if(!System::isNull($params, 'MASUK')){
			$awal = $params['MASUK']." 00:00:00";
			$akhir = $params['MASUK']." 23:59:59";
			$select->where("(tagihan_klaim.MASUK BETWEEN '$awal' AND '$akhir')");
			unset($params['MASUK']);
		}

		if(isset($params['KELUAR'])) if(!System::isNull($params, 'KELUAR')){
			$awal = $params['KELUAR']." 00:00:00";
			$akhir = $params['KELUAR']." 23:59:59";
			$select->where("(tagihan_klaim.KELUAR BETWEEN '$awal' AND '$akhir')");
			unset($params['KELUAR']);
		}

		$awal = $akhir = "";
		if(isset($params['AWAL'])) {
			$awal = $params['AWAL']." 00:00:00";
			unset($params['AWAL']);
		}
		if(isset($params['AKHIR'])) {
			$awal = $params['AKHIR']." 23:59:59";
			unset($params['AKHIR']);
		}
		if($awal != "" && $akhir != "") $select->where("(tagihan_klaim.TANGGAL_FINAL BETWEEN '$awal' AND '$akhir')");
	}
}