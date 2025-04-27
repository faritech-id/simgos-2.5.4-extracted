<?php
namespace Layanan\V1\Rest\TindakanMedis;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;
use Laminas\Db\Sql\Select;
use Laminas\Db\Sql\Expression;
use DBService\System;
use DBService\generator\Generator;
use Layanan\V1\Rest\PetugasTindakanMedis\PetugasTindakanMedisService;
use Pendaftaran\V1\Rest\Kunjungan\KunjunganService;
use Aplikasi\V1\Rest\Pengguna\PenggunaService;
use General\V1\Rest\Dokter\DokterService;
use General\V1\Rest\Perawat\PerawatService;
use Pembayaran\V1\Rest\Tagihan\TagihanService;
use General\V1\Rest\Referensi\ReferensiService;

class TindakanMedisService extends Service
{
	private $petugas;
	private $kunjungan;
	private $isCreate = false;
	private $pengguna;
	private $dokter;
	private $perawat;
	private $tagihan;
	private $Referensi;
	
	protected $references = [
		'Kunjungan' => true
	];
	
    public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "Layanan\\V1\\Rest\\TindakanMedis\\TindakanMedisEntity";
		$this->config["autoIncrement"] = false;
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("tindakan_medis", "layanan"));
		$this->entity = new TindakanMedisEntity();
		$this->petugas = new PetugasTindakanMedisService();
		$this->pengguna = new PenggunaService();
		$this->dokter = new DokterService();
		$this->perawat = new PerawatService();
		$this->Referensi = new ReferensiService();

		$this->tagihan = new TagihanService(false);
		
		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;

		if($includeReferences) {			
			if($this->references['Kunjungan']) $this->kunjungan = new KunjunganService();
		}
    }
	
	public function load($params = [], $columns = ['*'], $orders = []) {		
		$data = parent::load($params, $columns, $orders);
		
		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['Kunjungan']) {
					if(is_object($this->references['Kunjungan'])) {
						$references = isset($this->references['Kunjungan']->REFERENSI) ? (array) $this->references['Kunjungan']->REFERENSI : [];
						$this->kunjungan->setReferences($references, true);
						if(isset($this->references['Kunjungan']->COLUMNS)) $this->kunjungan->setColumns((array) $this->references['Kunjungan']->COLUMNS);
					}
					$kunjungan = $this->kunjungan->load(['kunjungan.NOMOR' => $entity['KUNJUNGAN']]);
					if(count($kunjungan) > 0) $entity['REFERENSI']['KUNJUNGAN'] = $kunjungan[0];
				}
				$results = $this->parseReferensi($entity, "JENIS_TINDAKAN");
				if(count($results) > 0) $entity["REFERENSI"]["JENIS_TINDAKAN"] = $results;
				$results = $this->parseReferensi($entity, "pengguna");
				if(count($results) > 0) $entity["REFERENSI"]["PENGGUNA"] = $results;
			}
		}
		
		return $data;
	}
        
	protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
		if($isCreated) $entity->set("ID", Generator::generateIdTindakanMedis());
		$this->isCreate = $isCreated;
		if(!$isCreated) {
			if(isset($this->data)) {
				if(count($this->data) > 0) {
					if($this->data[0]["OTOMATIS"] == 1) {
						if(isset($data["STATUS"])) {
							if($data["STATUS"] != 0) unset($data["OLEH"]);
						} else unset($data["OLEH"]);
					}
				}
			}
		}
	}

	protected function onAfterSaveCallback($id, $data) {
		$this->simpanPetugas($data, $id);
		if(!$this->isCreate) return;
		if(!isset($data['PETUGAS_MEDIS'])) {
			if(!empty($data["OLEH"])) {
				$pegawai = $this->pengguna->getPegawai($data["OLEH"]);
				if($pegawai) {
					$tenagamedis = null;
					if($pegawai["PROFESI"] == 4) { // dokter
						$dokter = $this->dokter->load([
							"NIP" => $pegawai["NIP"],
							"STATUS" => 1
						]);
						if(count($dokter) > 0) {
							$tenagamedis = [
								"TINDAKAN_MEDIS" => $id,
								"JENIS" => 1,
								"MEDIS" => $dokter[0]["ID"]			
							];
						}
					}
					if($pegawai["PROFESI"] == 6 || $pegawai["PROFESI"] == 3) { // perawat dan bidan
						$perawat = $this->perawat->load([
							"NIP" => $pegawai["NIP"],
							"STATUS" => 1
						]);
						if(count($perawat) > 0) {
							$jenis = 3;
							if($pegawai["PROFESI"] == 3) $jenis = 5;
							$tenagamedis = [
								"TINDAKAN_MEDIS" => $id,
								"JENIS" => $jenis,
								"MEDIS" => $perawat[0]["ID"]
							];
						}
					}

					if($tenagamedis) {
						$finds = $this->petugas->load($tenagamedis);
						if(count($finds) == 0) $this->petugas->simpanData($tenagamedis, true, false);
					}
				}
			}
		}
	}
	
	private function simpanPetugas($data, $id) {
		if(isset($data['PETUGAS_MEDIS'])) {
			foreach($data['PETUGAS_MEDIS'] as $tgs) {
				$tgs['TINDAKAN_MEDIS'] = $id;
				$this->petugas->simpanData($tgs, !is_numeric($tgs['ID']), false);
			}
		}
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(isset($params["ID"])) {
			$params["tindakan_medis.ID"] = $params["ID"];
			unset($params["ID"]);
		}
		
		if(!System::isNull($params, 'STATUS')) {
			$params['tindakan_medis.STATUS'] =  $params['STATUS'];
			unset($params['STATUS']);
		}		
		
		$select->join(
			['t' => new TableIdentifier('tindakan', 'master')],
			't.ID = TINDAKAN',
			['TINDAKAN_DESKRIPSI' => 'NAMA']
		);

		if(!System::isNull($params, 'NAMA')) {
			$select->where->like("t.NAMA", "%".$params['NAMA']."%");
			unset($params['NAMA']);
		}

		$select->join(
			['ref' => new TableIdentifier('referensi', 'master')],
			new \Laminas\Db\Sql\Predicate\Expression("ref.JENIS = 74 AND ref.ID = t.JENIS"),			
			['JENIS_TINDAKAN_DESKRIPSI' => 'DESKRIPSI']
		);

		if(!System::isNull($params, 'JENIS_TINDAKAN')) {
			$params['t.JENIS'] = $params['JENIS_TINDAKAN'];
			unset($params['JENIS_TINDAKAN']);
		}
		
		$select->join(
			['u' => new TableIdentifier('pengguna', 'aplikasi')],
			'u.ID = OLEH',
			['pengguna_NAMA' => 'NAMA']
		);
		
		$select->join(
			['p' => new TableIdentifier('pegawai', 'master')],
			'p.NIP = u.NIP',
			['pengguna_GELAR_DEPAN' => 'GELAR_DEPAN', 'pengguna_GELAR_BELAKANG' => 'GELAR_BELAKANG'],
			Select::JOIN_LEFT
		);

		if(!System::isNull($params, 'NORM') || !System::isNull($params, 'NOPEN')) {
			$norm = isset($params['NORM']) ? $params['NORM'] : "";
			$nopen = isset($params['NOPEN']) ? $params['NOPEN'] : "";

			$select->join(
				['k' => new TableIdentifier('kunjungan', 'pendaftaran')],
				'k.NOMOR = tindakan_medis.KUNJUNGAN',
				[]
			);
			$select->join(
				['pdftrn' => new TableIdentifier('pendaftaran', 'pendaftaran')],
				'pdftrn.NOMOR = k.NOPEN',
				[]
			);
			
			if(isset($params['NORM'])) {
				$select->where(['pdftrn.NORM' => $norm]);
				unset($params['NORM']);
			}

			if(isset($params['NOPEN'])) {
				$select->where(['pdftrn.NOMOR' => $nopen]);
				unset($params['NOPEN']);
			}			
		}

		if($this->user) {				
			$usr = $this->user;
			if(!$this->cekMemilikiaAksesLab()) $select->where('t.PRIVACY = 0');
		}
	}

	public function getKunjungan() {
	    return $this->kunjungan;
	}

	public function getTagihan() {
		return $this->tagihan;
	}

	public function cekMemilikiaAksesLab() {
		$result = $this->execute("SELECT aplikasi.aksesRuanganBerdasarkanJenis(?) ADA", [$this->user]);
		if(count($result) > 0) {
			if($result[0]["ADA"] == 'TRUE') return true;
		}
		
		return false;
	}
	
	public function getDataBerkasKlaimObatLabKlinik($data){
		$adapter = $this->table->getAdapter();
		
		if (isset($data->TINDAKAN_DESKRIPSI)) {
			$strLmt = $adapter->query("SELECT tm.*
				, td.NAMA TINDAKAN_DESKRIPSI
				, ref.ID IDREFERENSITINDAKAN
				, IFNULL (peg.GELAR_BELAKANG, '') 
				, IFNULL (peg.GELAR_DEPAN, '') GELAR_DEPAN
				, IFNULL (peg.NAMA, '') NAMA
				FROM pendaftaran.pendaftaran a
				, pendaftaran.kunjungan k
				, layanan.tindakan_medis tm
				, layanan.hasil_lab hl
				, master.ruangan r
				, master.tindakan td
				, master.referensi ref
				, aplikasi.pengguna p
				LEFT JOIN master.pegawai peg ON peg.NIP = p.NIP
				WHERE a.NOMOR = k.NOPEN 
				AND k.NOMOR = tm.KUNJUNGAN 
				AND k.RUANGAN = r.ID 
				AND tm.TINDAKAN = td.ID 
				AND ref.JENIS = 74 
				AND ref.ID = td.JENIS 
				AND p.ID = tm.OLEH 
				AND tm.ID = hl.TINDAKAN_MEDIS
				AND NORM=? 
				AND DATE(a.TANGGAL) <= ? 
				AND r.JENIS_KUNJUNGAN=4 
				AND r.JENIS= 5 
				AND r.`STATUS` = 1 
				AND INSTR(r.DESKRIPSI,'Patologi Anatomi') = 0 
				AND td.NAMA LIKE '".$data->TINDAKAN_DESKRIPSI."%' GROUP BY tm.ID
			");
			
			$results = $strLmt->execute(array($data->NORM,$data->TANGGAL));
		}
		else {
			$strLmt = $adapter->query("SELECT tm.*
				, td.NAMA TINDAKAN_DESKRIPSI
				, ref.ID IDREFERENSITINDAKAN
				, IFNULL (peg.GELAR_BELAKANG, '') 
				, IFNULL (peg.GELAR_DEPAN, '') GELAR_DEPAN
				, IFNULL (peg.NAMA, '') NAMA
				FROM pendaftaran.pendaftaran a
				, pendaftaran.kunjungan k
				, layanan.tindakan_medis tm
				, layanan.hasil_lab hl
				, master.ruangan r
				, master.tindakan td
				, master.referensi ref
				, aplikasi.pengguna p
				LEFT JOIN master.pegawai peg ON peg.NIP = p.NIP
				WHERE a.NOMOR = k.NOPEN 
				AND k.NOMOR = tm.KUNJUNGAN 
				AND k.RUANGAN = r.ID 
				AND tm.TINDAKAN = td.ID 
				AND ref.JENIS = 74 
				AND ref.ID = td.JENIS 
				AND p.ID = tm.OLEH 
				AND tm.ID = hl.TINDAKAN_MEDIS
				AND NORM=? 
				AND DATE(a.TANGGAL) <= ? 
				AND r.JENIS_KUNJUNGAN=4 
				AND r.JENIS= 5 
				AND r.`STATUS` = 1 
				AND INSTR(r.DESKRIPSI,'Patologi Anatomi') = 0 GROUP BY tm.ID
			");
			
			$results = $strLmt->execute(array($data->NORM,$data->TANGGAL));
		}
		
		$data = array();
		if(count($results) > 0){
			foreach($results as $row) {
				$kunjungans = $this->kunjungan->load(['kunjungan.NOMOR' => $row['KUNJUNGAN']]);
				if(count($kunjungans) > 0) $row['REFERENSI']['KUNJUNGAN'] = $kunjungans[0];
				
				$tindakans = $this->Referensi->load(['ID' => $row['IDREFERENSITINDAKAN'], 'JENIS' => 74]);
				if(count($tindakans) > 0) $row['REFERENSI']['JENIS_TINDAKAN']['DESKRIPSI'] = $tindakans[0]['DESKRIPSI'];
				
				$penggunas = $this->pengguna->load(['ID' => $row['OLEH']]);
				if(count($penggunas) > 0) $row['REFERENSI']['PENGGUNA'] = [
					"GELAR_BELAKANG" => $row["GELAR_BELAKANG"],
					"GELAR_DEPAN" => $row["GELAR_DEPAN"],
					"NAMA" => $row["NAMA"]
				];
				
				$data[] = $row;
			}
			return $data;
		} else {
			return $data;
		}
	}
}