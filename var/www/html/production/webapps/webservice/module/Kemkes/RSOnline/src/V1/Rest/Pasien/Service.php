<?php
namespace Kemkes\RSOnline\V1\Rest\Pasien;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;
use Laminas\Db\Sql\Select;
use DBService\System;

use Kemkes\RSOnline\db\referensi\jenis_kelamin\Service as JenisKelaminService;
use Kemkes\RSOnline\db\referensi\kewarganegaraan\Service as KewarganegaraanService;
use Kemkes\RSOnline\db\referensi\sumber_penularan\Service as SumberPenularanService;
use Kemkes\RSOnline\db\referensi\propinsi\Service as PropinsiService;
use Kemkes\RSOnline\db\referensi\kabupaten\Service as KabupatenService;
use Kemkes\RSOnline\db\referensi\kecamatan\Service as KecamatanService;
use Kemkes\RSOnline\db\referensi\status_keluar\Service as StatusKeluarService;
use Kemkes\RSOnline\db\referensi\status_rawat\Service as StatusRawatService;
use Kemkes\RSOnline\db\referensi\status_isolasi\Service as StatusIsolasiService;

class Service extends DBService {
	private $jenisKelamin;
	private $kewarganegaraan;
	private $sumberPenularan;
	private $propinsi;
	private $kabupaten;
	private $kecamatan;
	private $statusKeluar;
	private $statusRawat;
	private $statusIsolasi;	

	protected $references = [
		'JenisKelamin' => true,
		'Kewarganegaraan' => true,
		'SumberPenularan' => true,
		'Kecamatan' => true,
		'StatusKeluar' => true,
		'StatusRawat' => true,
		'StatusIsolasi' => true,		
	];
	
	public function __construct($includeReferences = true, $references = []) {
        $this->config["entityName"] = "Kemkes\\RSOnline\\V1\\Rest\\Pasien\\PasienEntity";
		$this->config["entityId"] = "nomr";
		$this->config["autoIncrement"] = false;
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("pasien", "kemkes-rsonline"));
		$this->entity = new PasienEntity();

		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;

		if($includeReferences) {
			if($this->references['JenisKelamin']) $this->jenisKelamin = new JenisKelaminService();
			if($this->references['Kewarganegaraan']) $this->kewarganegaraan = new KewarganegaraanService();
			if($this->references['SumberPenularan']) $this->sumberPenularan = new SumberPenularanService();
			if($this->references['Kecamatan']) {
				$this->propinsi = new PropinsiService();
				$this->kabupaten = new KabupatenService();
				$this->kecamatan = new KecamatanService();
			}
			if($this->references['StatusKeluar']) $this->statusKeluar = new StatusKeluarService();
			if($this->references['StatusRawat']) $this->statusRawat = new StatusRawatService();
			if($this->references['StatusIsolasi']) $this->statusIsolasi = new StatusIsolasiService();
        }
	}
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		
		if($this->includeReferences) {
            foreach($data as &$entity) {
                if($this->references['JenisKelamin']) {
                    $referensi = $this->jenisKelamin->load(['id_gender' => $entity['gender']]);
                    if(count($referensi) > 0) $entity['REFERENSI']['Gender'] = $referensi[0];
				}                                
				if($this->references['Kewarganegaraan']) {
                    $referensi = $this->kewarganegaraan->load(['id_nation' => $entity['kewarganegaraan']]);
                    if(count($referensi) > 0) $entity['REFERENSI']['Kewarganegaraan'] = $referensi[0];
				}
				if($this->references['SumberPenularan']) {
                    $referensi = $this->sumberPenularan->load(['id_source' => $entity['sumber_penularan']]);
                    if(count($referensi) > 0) $entity['REFERENSI']['SumberPenularan'] = $referensi[0];
				}
				if($this->references['Kecamatan']) {
                    $referensi = $this->kecamatan->load(['kode' => $entity['kecamatan']]);
					if(count($referensi) > 0) {
						$entity['REFERENSI']['Kecamatan'] = $referensi[0];
						$referensi = $this->kabupaten->load(['kode' => $referensi[0]["kabkota"]]);
                    	if(count($referensi) > 0) {
							$entity['REFERENSI']['Kabupaten'] = $referensi[0];
							$referensi = $this->propinsi->load(['prop_kode' => $referensi[0]["propinsi"]]);
							$entity['REFERENSI']['Propinsi'] = $referensi[0];
						}
					}										
				}
				if($this->references['StatusKeluar']) {
                    $referensi = $this->statusKeluar->load(['id_status' => $entity['status_keluar']]);
                    if(count($referensi) > 0) $entity['REFERENSI']['StatusKeluar'] = $referensi[0];
				}
				if($this->references['StatusRawat']) {
                    $referensi = $this->statusRawat->load(['id_status_rawat' => $entity['status_rawat']]);
                    if(count($referensi) > 0) $entity['REFERENSI']['StatusRawat'] = $referensi[0];
				}
				if($this->references['StatusIsolasi']) {
                    $referensi = $this->statusIsolasi->load(['id_isolasi' => $entity['status_isolasi']]);
                    if(count($referensi) > 0) $entity['REFERENSI']['StatusIsolasi'] = $referensi[0];
				}
            }
        }
		
		return $data;
	}

	protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
		$jk = isset($data["gender"]) ? $data["gender"] : "";
		$warga = isset($data["nationality"]) ? $data["nationality"] : (isset($data["negara"]) ?  $data["negara"] : "");
		$sumber = isset($data["sources"]) ? $data["sources"] : (isset($data["sumber_penularan"]) ? $data["sumber_penularan"] : "");
		$prop = isset($data["propinsi_name"]) ? $data["propinsi_name"] : "";
		$kab = isset($data["kabkota"]) ? $data["kabkota"] : "";
		$kec = isset($data["kecamatan"]) ? $data["kecamatan"] : "";
		$sk = isset($data["status_keluar"]) ? $data["status_keluar"] : "";
		$sr = isset($data["status_rawat"]) ? $data["status_rawat"] : "";
		$si = isset($data["status_isolasi"]) ? $data["status_isolasi"] : "";

		if($jk != "" && !is_numeric($jk)) {
			$found = $this->jenisKelamin->load([
				"gender" => trim($jk)
			]);
			if(count($found) > 0) $this->entity->set("gender", $found[0]["id_gender"]);
		}
		if($warga != "" && !is_numeric($warga)) {
			$found = $this->kewarganegaraan->load([
				"nationality" => trim($warga)
			]);
			if(count($found) > 0) $this->entity->set("kewarganegaraan", $found[0]["id_nation"]);
		}
		if($sumber != "" && !is_numeric($sumber)) {
			$found = $this->sumberPenularan->load([
				"sources" => trim($sumber)
			]);
			if(count($found) > 0) $this->entity->set("sumber_penularan", $found[0]["id_source"]);
		}
		$kodeProp = "";
		if($prop != "" && !is_numeric($prop)) {
			$found = $this->propinsi->load([
				"propinsi_name" => trim($prop)
			]);		
			if(count($found) > 0) $kodeProp = $found[0]["prop_kode"];
		}
		$kodeKab = "";
		if($kab != "" && !is_numeric($kab) && $kodeProp != "") {
			$params = [
				"nama" => trim($kab),
				"propinsi" => $kodeProp
			];
			//$params[] = new \Laminas\Db\Sql\Predicate\Like("kode", $kodeProp."%");
			$found = $this->kabupaten->load($params);
			if(count($found) > 0) $kodeKab = $found[0]["kode"];
		}
		if($kec != "" && !is_numeric($kec) && $kodeKab != "") {
			$params = [
				"nama" => trim($kec),
				"kabkota" => $kodeKab
			];
			//$params[] = new \Laminas\Db\Sql\Predicate\Like("kode", $kodeKab."%");
			$found = $this->kecamatan->load($params);
			if(count($found) > 0) $this->entity->set("kecamatan", $found[0]["kode"]);
		}
		if($sk != "" && !is_numeric($sk)) {
			$found = $this->statusKeluar->load([
				"status" => trim($sk)
			]);
			if(count($found) > 0) $this->entity->set("status_keluar", $found[0]["id_status"]);
		}
		if($sr != "" && !is_numeric($sr)) {
			$found = $this->statusRawat->load([
				"status" => trim($sr)
			]);
			if(count($found) > 0) $this->entity->set("status_rawat", $found[0]["id_status_rawat"]);
		}
		if($si != "" && !is_numeric($si)) {
			$found = $this->statusIsolasi->load([
				"status_isolasi" => trim($si)
			]);
			if(count($found) > 0) $this->entity->set("status_isolasi", $found[0]["id_isolasi"]);
		}
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'query')) {
			$query = $params["query"];
			unset($params['query']);
			$params[] = new \Laminas\Db\Sql\Predicate\Expression("(noc LIKE ? OR nomr LIKE ? OR nama_lengkap LIKE ?)", [$params["query"]."%", $params["query"]."%", "%".$params["query"]."%"]);			
		}		
	}

	public function statistikPasien() {
		return $this->execute("CALL `kemkes-rsonline`.statistikPasien()");
	}
}