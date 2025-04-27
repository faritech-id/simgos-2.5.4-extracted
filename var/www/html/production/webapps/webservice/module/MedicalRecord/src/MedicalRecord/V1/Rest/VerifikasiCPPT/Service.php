<?php
namespace MedicalRecord\V1\Rest\VerifikasiCPPT;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use Aplikasi\V1\Rest\Pengguna\PenggunaService;
use Pendaftaran\V1\Rest\Kunjungan\KunjunganService;

class Service extends DBService {
	private $pengguna;
	private $kunjungan;

	protected $references = [
		"Kunjungan" => true
	];
	

	public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\VerifikasiCPPT\\VerifikasiCPPTEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("verifikasi_cppt", "medicalrecord"));
		$this->entity = new VerifikasiCPPTEntity();

        $this->setReferences($references);		
		$this->includeReferences = $includeReferences;
		
		if($this->references['Kunjungan']){
			 $this->kunjungan = new KunjunganService(true, [
				'Ruangan' => false,
				'Referensi' => false,
				'Pendaftaran' => true,
				'RuangKamarTidur' => false,
				'PasienPulang' => false,
				'Pembatalan' => false,
				'Perujuk' => false,
				'Mutasi' => false
			]);
		}
	}

    public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		if($this->includeReferences) {
			foreach($data as &$entity) {
				$results = $this->parseReferensi($entity, "pengguna");
				if(count($results) > 0) $entity["REFERENSI"]["PENGGUNA"] = $results;
			}	
		}

		return $data;
	}

    protected function queryCallback(Select &$select, &$params, $columns, $orders) {
        if(!System::isNull($params, 'STATUS')) {
			$status = $params['STATUS'];
			$params['verifikasi_cppt.STATUS'] = $status;
			unset($params['STATUS']);
		}

		if(!System::isNull($params, 'ID')) {
			$id = $params['ID'];
			$params['verifikasi_cppt.ID'] = $id;
			unset($params['ID']);
		}

		$select->join(
			['u' => new TableIdentifier('pengguna', 'aplikasi')],
			'u.ID = OLEH',
			[]
		);
		
		$select->join(
			['p' => new TableIdentifier('pegawai', 'master')],
			'p.NIP = u.NIP',
			['pengguna_GELAR_DEPAN' => 'GELAR_DEPAN', 'pengguna_NAMA' => 'NAMA', 'pengguna_GELAR_BELAKANG' => 'GELAR_BELAKANG'],
			Select::JOIN_LEFT
		);
	}

	public function cekDPJPKunjungan($nomorkjgn, $nipuser){
		$statusdpjp = false;
		$data = $this->kunjungan->load(["NOMOR" => $nomorkjgn]);
		
		if(count($data) > 0){
			$reckjgn = $data[0];
			$refskjgn = $reckjgn['REFERENSI'];
			$dokter = isset($refskjgn["DPJP"]) ? $refskjgn["DPJP"] : false;

			if (!$dokter) {
				$pdftrn = isset($refskjgn["PENDAFTARAN"]) ? $refskjgn["PENDAFTARAN"] : false ;
				$tujuan = $pdftrn ? isset($pdftrn["TUJUAN"]) ? $pdftrn["TUJUAN"]  : false : false;
				$reftujuan = $tujuan ? isset($tujuan["REFERENSI"]) ? $tujuan["REFERENSI"] : false : false;
				$dokter = $reftujuan ? isset($reftujuan["DOKTER"]) ? $reftujuan["DOKTER"] : $dokter : $dokter;
			}

			if ($dokter) $statusdpjp = $nipuser == $dokter["NIP"];

		}
		return $statusdpjp;
	}
}