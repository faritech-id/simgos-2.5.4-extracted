<?php
namespace Layanan\V1\Rest\StatusHasilPemeriksaan;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use MedicalRecord\V1\Rest\JadwalKontrol\Service as JadwalKontrol;

class Service extends DBService {
	public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "Layanan\\V1\\Rest\\StatusHasilPemeriksaan\\StatusHasilPemeriksaanEntity";		
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("status_hasil_pemeriksaan", "layanan"));
		$this->entity = new StatusHasilPemeriksaanEntity();
		$this->jadwal = new JadwalKontrol(false);
	}

	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);

		if($this->includeReferences) {
			foreach($data as &$entity) {
				$results = $this->parseReferensi($entity, "tindakan");
				if(count($results) > 0) $entity["REFERENSI"]["TINDAKAN"] = $results;
				$results = $this->parseReferensi($entity, "kunjungan");
				if(count($results) > 0) $entity["REFERENSI"]["KUNJUNGAN"] = $results;
				$results = $this->parseReferensi($entity, "pendaftaran");
				if(count($results) > 0) {
					$entity["REFERENSI"]["PENDAFTARAN"] = $results;
					$jadwal = $this->jadwal->load(['HISTORY' => 1, 'NOPEN' => $results["NOMOR"]]);
					if(count($jadwal) > 0) $entity['REFERENSI']['JADWAL_KONTROL'] = $jadwal[0];
				}
				$results = $this->parseReferensi($entity, "pasien");
				if(count($results) > 0) $entity["REFERENSI"]["PASIEN"] = $results;
				$results = $this->parseReferensi($entity, "ruangan");
				if(count($results) > 0) $entity["REFERENSI"]["RUANGAN"] = $results;
				$results = $this->parseReferensi($entity, "pengirim");
				if(count($results) > 0) $entity["REFERENSI"]["RUANGAN_PENGIRIM"] = $results;
				$results = $this->parseReferensi($entity, "status_hasil");
				if(count($results) > 0) $entity["REFERENSI"]["STATUS_HASIL"] = $results;
				$results = $this->parseReferensi($entity, "status_pengiriman");
				if(count($results) > 0) $entity["REFERENSI"]["STATUS_PENGIRIMAN_HASIL"] = $results;
			}	
		}

		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		$jenis = 0;
		if(!System::isNull($params, 'JENIS')) {
			$jenis = $params['JENIS'];
			$params['status_hasil_pemeriksaan.JENIS'] = $jenis;
			unset($params['JENIS']);
		}
		
		$awal = $akhir = "";
		if(!System::isNull($params, 'PERIODE_AWAL')) {
			$awal = $params['PERIODE_AWAL'];
			unset($params['PERIODE_AWAL']);
		}
		if(!System::isNull($params, 'PERIODE_AKHIR')) {
			$akhir = $params['PERIODE_AKHIR'];
			unset($params['PERIODE_AKHIR']);
		}
		$group = false;
		if(!System::isNull($params, 'GROUP_PEMERIKSAAN')) {
			$group = $params['GROUP_PEMERIKSAAN'];
			unset($params['GROUP_PEMERIKSAAN']);
		}

		if(!System::isNull($params, 'ID')) {
			$id = $params['ID'];
			$select->where("status_hasil_pemeriksaan.ID = ".$id);
			unset($params['ID']);
		}

		$select->join(
			["tm" => new TableIdentifier('tindakan_medis', 'layanan')],
			new \Laminas\Db\Sql\Predicate\Expression("tm.ID = status_hasil_pemeriksaan.TINDAKAN_MEDIS_ID AND tm.STATUS = 1"),
			[]
		);
		$select->join(
			["ref1" => new TableIdentifier('referensi', 'master')],
			new \Laminas\Db\Sql\Predicate\Expression("ref1.ID = status_hasil_pemeriksaan.STATUS_HASIL AND ref1.JENIS = 208"),
			['status_hasil_ID' => 'ID', 'status_hasil_DESKRIPSI' => 'DESKRIPSI', 'status_hasil_CONFIG' => 'CONFIG']
		);
		$select->join(
			["ref2" => new TableIdentifier('referensi', 'master')],
			new \Laminas\Db\Sql\Predicate\Expression("ref2.ID = status_hasil_pemeriksaan.STATUS_PENGIRIMAN_HASIL AND ref2.JENIS = 209"),
			['status_pengiriman_ID' => 'ID', 'status_pengiriman_DESKRIPSI' => 'DESKRIPSI', 'status_pengiriman_CONFIG' => 'CONFIG']
		);
		$select->join(
			["t" => new TableIdentifier('tindakan', 'master')],
			"t.ID = tm.TINDAKAN",
			['tindakan_NAMA' => 'NAMA']
		);
		$select->join(
			["k" => new TableIdentifier('kunjungan', 'pendaftaran')],
			new \Laminas\Db\Sql\Predicate\Expression("k.NOMOR = tm.KUNJUNGAN AND k.STATUS IN (1, 2)"),
			['kunjungan_NOMOR' => 'NOMOR', 'kunjungan_MASUK' => 'MASUK']
		);
		$select->join(
			["p" => new TableIdentifier('pendaftaran', 'pendaftaran')],
			"p.NOMOR = k.NOPEN",
			['pendaftaran_NOMOR' => 'NOMOR', 'pendaftaran_TANGGAL' => 'TANGGAL']
		);
		$select->join(
			["ps" => new TableIdentifier('pasien', 'master')],
			"ps.NORM = p.NORM",
			[
				'pasien_NORM' => 'NORM',
				'pasien_GELAR_DEPAN' => 'GELAR_DEPAN',
				'pasien_NAMA' => 'NAMA',
				'pasien_GELAR_BELAKANG' => 'GELAR_BELAKANG',
				'pasien_TANGGAL_LAHIR' => 'TANGGAL_LAHIR'
			]
		);
		$select->join(
			["r" => new TableIdentifier('ruangan', 'master')],
			"r.ID = k.RUANGAN",
			['ruangan_DESKRIPSI' => 'DESKRIPSI']
		);
		$ordername = "";

		if($group) {
			$select->join(
				["mgp" => new TableIdentifier('mapping_group_pemeriksaan', 'master')],
				new \Laminas\Db\Sql\Predicate\Expression("mgp.PEMERIKSAAN = tm.TINDAKAN"),
				[]
			);
			$select->where("mgp.GROUP_PEMERIKSAAN_ID = ".$group." AND mgp.STATUS = 1");
		}

		if($jenis == 7) $ordername = "order_rad";
		if($jenis == 8) $ordername = "order_lab";
		if($ordername != "") {
			$select->join(
				["o" => new TableIdentifier($ordername, 'layanan')],
				new \Laminas\Db\Sql\Predicate\Expression("o.NOMOR = k.REF"),
				[],
				Select::JOIN_LEFT
			);
			$select->join(
				["ka" => new TableIdentifier('kunjungan', 'pendaftaran')],
				new \Laminas\Db\Sql\Predicate\Expression("ka.NOMOR = o.KUNJUNGAN AND ka.STATUS IN (1, 2)"),
				[]
			);
			$select->join(
				["ra" => new TableIdentifier('ruangan', 'master')],
				"ra.ID = ka.RUANGAN",
				['pengirim_DESKRIPSI' => 'DESKRIPSI']
			);

			if(!System::isNull($params, 'RUANGAN_ASAL')) {
				$params['ka.RUANGAN'] = $params['RUANGAN_ASAL'];
				unset($params['RUANGAN_ASAL']);
			}

			if(!System::isNull($params, 'RUANGAN_TUJUAN')) {
				$params['o.TUJUAN'] = $params['RUANGAN_TUJUAN'];
				unset($params['RUANGAN_TUJUAN']);
			}

			if(!System::isNull($params, 'DOKTER_ASAL')) {
				$params['o.DOKTER_ASAL'] = $params['DOKTER_ASAL'];
				unset($params['DOKTER_ASAL']);
			}
		}

		if($jenis == 7) {
			$select->join(
				["hr" => new TableIdentifier("hasil_rad", 'layanan')],
				new \Laminas\Db\Sql\Predicate\Expression("hr.TINDAKAN_MEDIS = tm.ID"),
				['KRITIS'],
				Select::JOIN_LEFT
			);

			if(!System::isNull($params, 'DOKTER_PEMERIKSA')) {
				$params['hr.DOKTER'] = $params['DOKTER_PEMERIKSA'];
				unset($params['DOKTER_PEMERIKSA']);
			}

			if(!System::isNull($params, 'VIEWALL_RAD')) {
				if($params["VIEWALL_RAD"] == true){
					unset($params['VIEWALL_RAD']);
				}else $params['hr.STATUS'] = "2";				
			}else $params['hr.STATUS'] = "2";
		}

		if($jenis == 8) {
			$select->join(
				["hr" => new TableIdentifier("hasil_lab", 'layanan')],
				new \Laminas\Db\Sql\Predicate\Expression("hr.TINDAKAN_MEDIS = tm.ID"),
				[],
				Select::JOIN_LEFT
			);
			$select->join(
				["nk" => new TableIdentifier("nilai_kritis_lab", 'layanan')],
				new \Laminas\Db\Sql\Predicate\Expression("nk.HASIL_LAB = hr.ID"),
				["KRITIS" => new \Laminas\Db\Sql\Predicate\Expression("IF(nk.ID IS NULL, 0, 1)")],
				Select::JOIN_LEFT
			);
			$select->join(
				["ctt" => new TableIdentifier("catatan_hasil_lab", 'layanan')],
				new \Laminas\Db\Sql\Predicate\Expression("ctt.KUNJUNGAN = k.NOMOR"),
				[],
				Select::JOIN_LEFT
			);
			if(!System::isNull($params, 'DOKTER_PEMERIKSA')) {
				$params['ctt.DOKTER'] = $params['DOKTER_PEMERIKSA'];
				unset($params['DOKTER_PEMERIKSA']);
			}

			if(!System::isNull($params, 'VIEWALL_LAB')) {
				if($params["VIEWALL_LAB"] == true){
					unset($params['VIEWALL_LAB']);
				}else $params['k.FINAL_HASIL'] = "1";		
			}else $params['k.FINAL_HASIL'] = "1";
		}

		if(!System::isNull($params, 'QUERY')) {
			$query = $params['QUERY'];
			$sql = new \Laminas\Db\Sql\Predicate\Like("ps.NAMA", $query."%");
			if(is_numeric($query)) $sql = "ps.NORM = ".$query;
			$select->where($sql);
			unset($params['QUERY']);
		}

		if($this->user) {				
			$usr = $this->user;
			if(!$this->cekMemilikiaAksesLab()) $select->where('t.PRIVACY = 0');
		}

		if($awal != "" && $akhir != "") {
			$select->where(new \Laminas\Db\Sql\Predicate\Between("o.TANGGAL", $awal." 00:00:00", $akhir." 23:59:59"));
		}
	}

	public function cekMemilikiaAksesLab() {
		$result = $this->execute("SELECT aplikasi.aksesRuanganBerdasarkanJenis(?) ADA", [$this->user]);
		if(count($result) > 0) {
			if($result[0]["ADA"] == 'TRUE') return true;
		}
		
		return false;
	}
}