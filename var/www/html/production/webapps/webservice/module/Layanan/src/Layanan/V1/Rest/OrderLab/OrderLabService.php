<?php
namespace Layanan\V1\Rest\OrderLab;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;
use Laminas\Db\Sql\Select;
use Laminas\Db\Sql\Expression;
use DBService\System;
use DBService\generator\Generator;
use General\V1\Rest\Ruangan\RuanganService;
use General\V1\Rest\Pegawai\PegawaiService;
use General\V1\Rest\Referensi\ReferensiService;
use General\V1\Rest\Dokter\DokterService;
use Layanan\V1\Rest\OrderDetilLab\OrderDetilLabService;
use Pendaftaran\V1\Rest\Kunjungan\KunjunganService;
use Aplikasi\V1\Rest\Pengguna\PenggunaService;

class OrderLabService extends Service
{
	private $ruangan;
	private $referensi;
	private $detillab;
	private $dokter;
	private $kunjungan;
	private $pengguna;
	private $pegawai;
	private $kontakpegawai;
	
	protected $references = [
		'Ruangan' => true,
		'Referensi' => true,
		'Dokter' => true,
		'OrderDetil' => true,
		'Kunjungan' => true,
		'Pegawai' => true,
	];
	
    public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "Layanan\\V1\\Rest\\OrderLab\\OrderLabEntity";
		$this->config["entityId"] = "NOMOR";
		$this->config["autoIncrement"] = false;
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("order_lab", "layanan"));
		$this->entity = new OrderLabEntity();
		
		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {			
			if($this->references['Ruangan']) $this->ruangan = new RuanganService();
			if($this->references['Referensi']) $this->referensi = new ReferensiService();
			if($this->references['Dokter']) $this->dokter = new DokterService();
			if($this->references['OrderDetil']) $this->detillab = new OrderDetilLabService();
			if($this->references['Kunjungan']) $this->kunjungan = new KunjunganService();
			if($this->references['Pegawai']) $this->pegawai = new PegawaiService();
		}

		$this->pengguna = new PenggunaService();
    }

	protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
		if($isCreated) {
			$kunjungan = $this->kunjungan->load(['kunjungan.NOMOR' => $this->entity->get('KUNJUNGAN')]);
			if(count($kunjungan) > 0) {
				$nomor = Generator::generateNoOrderLab($kunjungan[0]['RUANGAN']);
				$entity->set('NOMOR', $nomor);
			}
		}
	}
	
	protected function onAfterSaveCallback($id, $data) {
		$this->SimpanDetilLab($data, $id);
	}
	
	private function SimpanDetilLab($data, $id) {
		if(isset($data['ORDER_DETIL'])) {
			foreach($data['ORDER_DETIL'] as $tgs) {
				$tgs['ORDER_ID'] = $id;
				$this->detillab->simpan($tgs);
			}
		}
	}
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		
		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['Kunjungan']) {
					if(is_object($this->references['Kunjungan'])) {
						if(!$this->kunjungan){
							$this->kunjungan = new KunjunganService();
						}
						$references = isset($this->references['Kunjungan']->REFERENSI) ? (array) $this->references['Kunjungan']->REFERENSI : [];
						$this->kunjungan->setReferences($references, true);
						if(isset($this->references['Kunjungan']->COLUMNS)) $this->kunjungan->setColumns((array) $this->references['Kunjungan']->COLUMNS);
					}
					$kunjungan = $this->kunjungan->load(['kunjungan.NOMOR' => $entity['KUNJUNGAN']]);
					if(count($kunjungan) > 0) $entity['REFERENSI']['KUNJUNGAN'] = $kunjungan[0];
				}
				if($this->references['Ruangan']) {
					if(is_object($this->references['Ruangan'])) {
						$references = isset($this->references['Ruangan']->REFERENSI) ? (array) $this->references['Ruangan']->REFERENSI : [];
						$this->ruangan->setReferences($references, true);
						if(isset($this->references['Ruangan']->COLUMNS)) $this->ruangan->setColumns((array) $this->references['Ruangan']->COLUMNS);
					}
					$ruangan = $this->ruangan->load(['ID' => $entity['TUJUAN']]);
					if(count($ruangan) > 0) $entity['REFERENSI']['TUJUAN'] = $ruangan[0];
				}
				if($this->references['Dokter']) {
					//if(is_object($this->references['Dokter'])) {
					//	$references = isset($this->references['Dokter']->REFERENSI) ? (array) $this->references['Dokter']->REFERENSI : [];
					//	$this->dokter->setReferences($references, true);
					//	if(isset($this->references['Dokter']->COLUMNS)) $this->dokter->setColumns((array) $this->references['Dokter']->COLUMNS);
					//}
					$dokter = $this->dokter->load(['ID' => $entity['DOKTER_ASAL']]);
					if(count($dokter) > 0) $entity['REFERENSI']['DOKTER_ASAL'] = $dokter[0];
				}
				if($this->references['Referensi']) {
					$referensi = $this->referensi->load(['JENIS' => 31,'ID' => $entity['STATUS']]);
					if(count($referensi) > 0) $entity['REFERENSI']['STATUS'] = $referensi[0];

					$referensi = $this->referensi->load(['JENIS' => 210, 'ID' => $entity['SPESIMEN_KLINIS_ASAL_SUMBER']]);
					if(count($referensi) > 0) $entity['REFERENSI']['SPESIMEN_KLINIS_ASAL_SUMBER'] = $referensi[0];
					
					$referensi = $this->referensi->load(['JENIS' => 211, 'ID' => $entity['SPESIMEN_KLINIS_CARA_PENGAMBILAN']]);
					if(count($referensi) > 0) $entity['REFERENSI']['SPESIMEN_KLINIS_CARA_PENGAMBILAN'] = $referensi[0];

					$referensi = $this->referensi->load(['JENIS' => 252, 'ID' => $entity['PERNAH_TRANSFUSI_DARAH']]);
					if(count($referensi) > 0) $entity['REFERENSI']['PERNAH_TRANSFUSI_DARAH'] = $referensi[0];

					$referensi = $this->referensi->load(['JENIS' => 253, 'ID' => $entity['SIFAT_PERMINTAAN']]);
					if(count($referensi) > 0) $entity['REFERENSI']['SIFAT_PERMINTAAN'] = $referensi[0];

					$referensi = $this->referensi->load(['JENIS' => 6, 'ID' => $entity['GOLONGAN_DARAH']]);
					if(count($referensi) > 0) $entity['REFERENSI']['GOLONGAN_DARAH'] = $referensi[0];

					$referensi = $this->referensi->load(['JENIS' => 254, 'ID' => $entity['RESUS']]);
					if(count($referensi) > 0) $entity['REFERENSI']['RESUS'] = $referensi[0];
				}
				if(!empty($entity['OLEH'])) {
					$pengguna = $this->pengguna->getPegawai($entity['OLEH']);
					if($pengguna) $entity['REFERENSI']['PETUGAS'] = $pengguna;
				}
				if($this->references['Pegawai']) {
					$pegawai = $this->pegawai->load(['ID' => $entity['SPESIMEN_KLINIS_PETUGAS_PENGAMBIL']]);
					if(count($pegawai) > 0) $entity['REFERENSI']['SPESIMEN_KLINIS_PETUGAS_PENGAMBIL'] = $pegawai[0];

					$pegawai = $this->pegawai->load(['ID' => $entity['SPESIMEN_KLINIS_PETUGAS_PENGANTAR']]);
					if(count($pegawai) > 0) $entity['REFERENSI']['SPESIMEN_KLINIS_PETUGAS_PENGANTAR'] = $pegawai[0];
				}
			}
		}
		
		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'STATUS')) {
			$params['order_lab.STATUS'] = !is_array($params['STATUS']) ? (strpos(strval($params['STATUS']), "]") > 0 ? (array) json_decode($params['STATUS']) : $params['STATUS']) : $params['STATUS'];
			unset($params['STATUS']);
		}
		
		if(!System::isNull($params, 'NOMOR')) {
			$params['order_lab.NOMOR'] = $params['NOMOR'];
			unset($params['NOMOR']);
		}
		
		$select->join(
			['kjgn' => new TableIdentifier('kunjungan', 'pendaftaran')],
			'kjgn.NOMOR = KUNJUNGAN',
			[]
		);
		
		$select->join(
			['p' => new TableIdentifier('pendaftaran', 'pendaftaran')],
			'p.NOMOR = kjgn.NOPEN',
			[]
		);
		
		if(!System::isNull($params, 'TANGGAL')) {
			if(!is_array($params["TANGGAL"])) {
				$tanggal = substr($params['TANGGAL'], 0, 10);
				$select->where->between("order_lab.TANGGAL", $tanggal." 00:00:00", $tanggal." 23:59:59");
			} else {
				$tanggal = $params["TANGGAL"]["VALUE"];
				$params["order_lab.TANGGAL"] = $tanggal;
			}
			unset($params['TANGGAL']);
		}
		
		if($this->user && $this->privilage) {
			$usr = $this->user;
			$join = "par.RUANGAN = order_lab.TUJUAN";
			$histori = false;
			if(!System::isNull($params, 'HISTORY')) {
				$join = "(par.RUANGAN = kjgn.RUANGAN)";
				$histori = true;
				unset($params['HISTORY']);
			}
			$select->join(["par" => new Expression(
				"(SELECT DISTINCT par.RUANGAN 
				FROM aplikasi.pengguna_akses_ruangan par
					 INNER JOIN `master`.ruangan r 
			   WHERE par.STATUS = 1 
				 AND par.PENGGUNA = $usr
				 AND r.ID = par.RUANGAN ".
				 (!$histori ? "AND r.JENIS_KUNJUNGAN = 4 " : "")."
				 AND r.JENIS = 5)")],
				 $join,
				[]
			);
			//$select->where("EXISTS(SELECT 1 FROM aplikasi.pengguna_akses_ruangan par WHERE par.RUANGAN = kjgn.RUANGAN AND par.PENGGUNA = ".$usr." AND par.STATUS = 1)");
		}
	}
	
	public function kunjunganSudahDiOrderLabkan($kunjungan) {
	    $found = $this->load([
	        "KUNJUNGAN" => $kunjungan,
	        "STATUS" => [1,2]
	    ]);
	    return count($found) > 0;
	}
}