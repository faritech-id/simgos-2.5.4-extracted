<?php
namespace Kemkes\db\siranap\tempat_tidur;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

use Kemkes\db\siranap\kelas\Service as KelasService;
use Kemkes\db\siranap\ruangan\Service as RuanganService;

class Service extends DBService {
	private $kelas;
	private $ruangan;

	public function __construct() {
		$this->config["entityName"] = "Kemkes\\db\\siranap\\tempat_tidur\\Entity";
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("tempat_tidur_kemkes", "informasi"));

		$this->kelas = new KelasService();
		$this->ruangan = new RuanganService();
	}
	
	public function getWithReference($params = []) {
		$tanggal = isset($params["tanggal"]) ? "STR_TO_DATE('".$params["tanggal"]."', '%d-%m-%Y')" : "DATE(NOW())";
		$data = $this->execute("CALL informasi.listBedMonitorKemkes(".$tanggal.", ".$tanggal.")");

		foreach($data as &$entity) {
			$kelas = $this->kelas->load(['ID' => $entity["kode_ruang"]]);
			if(count($kelas) > 0) $entity['REFERENSI']['KELAS'] = $kelas[0];

			$ruang = $this->ruangan->load(['ID' => $entity["tipe_pasien"]]);
			if(count($ruang) > 0) $entity['REFERENSI']['RUANGAN'] = $ruang[0];
		}
		return $data;
	}

	public function getKelas() {
		return $this->kelas;
	}

	public function getRuangan() {
		return $this->ruangan;
	}
}