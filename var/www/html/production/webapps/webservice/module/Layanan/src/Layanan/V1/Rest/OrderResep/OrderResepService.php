<?php
namespace Layanan\V1\Rest\OrderResep;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;
use Laminas\Db\Sql\Select;
use Laminas\Db\Sql\Expression;
use DBService\System;
use DBService\generator\Generator;
use General\V1\Rest\Ruangan\RuanganService;
use General\V1\Rest\Referensi\ReferensiService;
use General\V1\Rest\Dokter\DokterService;
use General\V1\Rest\Pegawai\PegawaiService;
use Layanan\V1\Rest\OrderDetilResep\OrderDetilResepService;
use Pendaftaran\V1\Rest\Kunjungan\KunjunganService;
use Aplikasi\V1\Rest\Pengguna\PenggunaService;

class OrderResepService extends Service
{
	private $ruangan;
	private $referensi;
	private $detilrad;
	private $dokter;
	private $kunjungan;

	private $pengguna;
	private $pegawai;
	
	protected $references = [
		'Ruangan' => true,
		'Referensi' => true,
		'Dokter' => true,
		'OrderDetil' => true,
		'Kunjungan' => true
	];
	
    public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "Layanan\\V1\\Rest\\OrderResep\\OrderResepEntity";
		$this->config["entityId"] = "NOMOR";
		$this->config["autoIncrement"] = false;
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("order_resep", "layanan"));
		$this->entity = new OrderResepEntity();
		
		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {
			if($this->references['Ruangan']) $this->ruangan = new RuanganService();
			if($this->references['Referensi']) $this->referensi = new ReferensiService();
			if($this->references['Dokter']) $this->dokter = new DokterService();
			if($this->references['OrderDetil']) $this->detilresep = new OrderDetilResepService();
			if($this->references['Kunjungan']) $this->kunjungan = new KunjunganService();
		}
		$this->pengguna = new PenggunaService();
		$this->pegawai = new PegawaiService();
    }

	protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
		if($isCreated) {
			$kunjungan = $this->kunjungan->load(['kunjungan.NOMOR' => $entity->get('KUNJUNGAN')]);
			if(count($kunjungan) > 0) {
				Generator::reinitialize();
				$nomor = Generator::generateNoOrderResep($kunjungan[0]['RUANGAN']);
				$this->entity->set('NOMOR', $nomor);
				if($this->entity->get('REF') == '0') $this->entity->set('REF', $nomor);
			}
		}
	}

	protected function onAfterSaveCallback($id, $data) {
		$this->SimpanDetilResep($data, $id);
	}
        
	private function SimpanDetilResep($data, $id) {
		if(isset($data['ORDER_DETIL'])) {
			foreach($data['ORDER_DETIL'] as $tgs) {
				if($tgs['STATUS_PEMBERIAN'] == 3){
					$tgs['ORDER_ID'] = $tgs['REF_RIWAYAT_ORDER'];
					$tgs['FARMASI'] = $tgs['REF_FARMASI'];
					$tgs['TANGGAL_STOP'] = $data['TANGGAL'];
					$tgs['USER_STOP'] = $data['OLEH'];
					$this->detilresep->stoporder($tgs);
				} else {
					$tgs['ORDER_ID'] = $id;
					$this->detilresep->simpan($tgs);
				}
			}
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
					$dokter = $this->dokter->load(['ID' => $entity['DOKTER_DPJP']]);
					if(count($dokter) > 0) $entity['REFERENSI']['DOKTER_DPJP'] = $dokter[0];
				}
				if($this->references['Referensi']) {
					$referensi = $this->referensi->load(['JENIS' => 31,'ID' => $entity['STATUS']]);
					if(count($referensi) > 0) $entity['REFERENSI']['STATUS'] = $referensi[0];
				}
				if(!empty($entity['OLEH'])) {
					$pengguna = $this->pengguna->getPegawai($entity['OLEH']);
					if($pengguna) $entity['REFERENSI']['PETUGAS'] = $pengguna;
				}
				if(!empty($entity['PEMBERI_RESEP'])) {
					if(is_numeric($entity['PEMBERI_RESEP'])) {
						$pengguna = $this->pegawai->load(['ID' => $entity['PEMBERI_RESEP']]);
						if($pengguna) $entity['PEMBERI_RESEP'] = $pengguna[0]['NAMA'];
					}
				}
			}
		}
		
		return $data;
	}
	
	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'STATUS')) {
			$params['order_resep.STATUS'] = !is_array($params['STATUS']) ? (strpos(strval($params['STATUS']), "]") > 0 ? (array) json_decode($params['STATUS']) : $params['STATUS']) : $params['STATUS'];
			unset($params['STATUS']);
		}
		
		if(!System::isNull($params, 'NOMOR')) {
			$params['order_resep.NOMOR'] = $params['NOMOR'];
			unset($params['NOMOR']);
		}
		
		$select->join(
			['kjgn' => new TableIdentifier('kunjungan', 'pendaftaran')],
			'kjgn.NOMOR = KUNJUNGAN',
			[]
		);
		
		if(!System::isNull($params, 'ASAL')) {
			$params['kjgn.RUANGAN'] = $params['ASAL'];
			unset($params['ASAL']);
		}

		$select->join(
			['p' => new TableIdentifier('pendaftaran', 'pendaftaran')],
			'p.NOMOR = kjgn.NOPEN',
			[]
		);

		if(!System::isNull($params, 'TANGGAL')) {
			if(!is_array($params["TANGGAL"])) {
				$tanggal = substr($params['TANGGAL'], 0, 10);
				$select->where->between("order_resep.TANGGAL", $tanggal." 00:00:00", $tanggal." 23:59:59");
			} else {
				$tanggal = $params["TANGGAL"]["VALUE"];
				$params["order_resep.TANGGAL"] = $tanggal;
			}
			unset($params['TANGGAL']);
		}
		
		if($this->user && $this->privilage) {
			$usr = $this->user;
			$histori = false;
			$join = "par.RUANGAN = order_resep.TUJUAN";
			if(!System::isNull($params, 'HISTORY')) {
				$join = "(par.RUANGAN = order_resep.TUJUAN OR par.RUANGAN = kjgn.RUANGAN)";
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
				 (!$histori ? "AND r.JENIS_KUNJUNGAN = 11 " : "")."
				 AND r.JENIS = 5)")],
				 $join,
				[]
			);
		}
	}

	public function kunjunganSudahDiOrderResepkan($kunjungan) {
	    $found = $this->load([
	        "KUNJUNGAN" => $kunjungan,
	        "STATUS" => [1,2]
	    ]);
	    return count($found) > 0;
	}

	public function getKunjungan() {
		return $this->kunjungan;
	}

	public function isNotValidateStok($data) {
		$result = false;
		if(isset($data->ORDER_DETIL)) {
			$isValidate = $this->resource->getPropertyConfig(49) == 'TRUE';
			if($isValidate) {
				foreach($data->ORDER_DETIL as $dtl) {
					if($dtl['STATUS_PEMBERIAN'] != 3){
						$barang = $dtl['FARMASI'];
						$jumlah = $dtl['JUMLAH'];
						$result = $this->execute("SELECT SUM(b.STOK) STOKRS FROM inventory.barang_ruangan b WHERE b.BARANG = ?", [$barang]);
						
						if(count($result) > 0) {
							if($result[0]["STOKRS"] < $jumlah) {
								return true;
								break;
							}
						}
					}
				}
			}
		}
	}

	public function isNotValidRetriksi($data) {
		$result = false;
		if(isset($data->ORDER_DETIL)) {
			$isValidate = $this->resource->getPropertyConfig(79) == 'TRUE';
			if($isValidate) {
				foreach($data->ORDER_DETIL as $dtl) {
					if($dtl['STATUS_PEMBERIAN'] != 3){
						$barang = $dtl['FARMASI'];
						$kunjungan = $data->KUNJUNGAN;
						$timestamp = strtotime($data->TANGGAL);
						$tanggal = date("Y-m-d", $timestamp);
						$result = $this->execute("SELECT 
												br.NAMA NMBARANG, DATE_FORMAT(bts.TANGGAL,'%d-%m-%Y') TGLBATAS, DATE_FORMAT(IF(kf.KELUAR IS NULL, f.TANGGAL, kf.KELUAR),'%d-%m-%Y') TGLLYN, f.JUMLAH, f.HARI
												FROM pendaftaran.kunjungan k
												LEFT JOIN master.ruangan r ON r.ID = k.RUANGAN
												, pendaftaran.pendaftaran p, layanan.batas_layanan_obat bts
												LEFT JOIN inventory.barang br ON br.ID = bts.FARMASI
												LEFT JOIN layanan.farmasi f ON f.ID = bts.REF
												LEFT JOIN pendaftaran.kunjungan kf ON kf.NOMOR = f.KUNJUNGAN
												LEFT JOIN master.ruangan r2 ON r2.ID = kf.RUANGAN
												LEFT JOIN layanan.order_resep res ON res.NOMOR = kf.REF
												LEFT JOIN pendaftaran.kunjungan kh ON kh.NOMOR = res.KUNJUNGAN
												LEFT JOIN master.ruangan r3 ON r3.ID = kh.RUANGAN
												WHERE bts.NORM = p.NORM AND bts.FARMASI = ? AND bts.STATUS = 1 AND bts.TANGGAL > ?  AND p.NOMOR = k.NOPEN AND k.NOMOR = ?
												AND r3.JENIS_KUNJUNGAN = r.JENIS_KUNJUNGAN", [$barang,$tanggal,$kunjungan]);
						
						if(count($result) > 0) {
							return array(
								"success" => true,
								"message" => "(".$tanggal.") Resep Gagal Di Kirim, Item Barang <b>".$result[0]["NMBARANG"]."</b> telah di layani pada tanggal <b>".$result[0]["TGLLYN"]."</b> sebanyak <b>".$result[0]["JUMLAH"]."</b> untuk <b>".$result[0]["HARI"]."</b> Hari kedepan, Obat dapat diresepkan kembali di tanggal <b>".$result[0]["TGLBATAS"]."</b>"
							);
							break;
						}
					}
				}
			}
		}
	}
}