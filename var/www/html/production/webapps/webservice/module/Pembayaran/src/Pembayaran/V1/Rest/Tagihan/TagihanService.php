<?php
namespace Pembayaran\V1\Rest\Tagihan;

use DBService\DatabaseService;
use Laminas\Db\Sql\Select;
use DBService\System;
use Zend\json\Json;
use DBService\Service;
use Laminas\Db\Sql\TableIdentifier;

use Pembayaran\V1\Rest\Diskon\DiskonService;
use Pembayaran\V1\Rest\DiskonDokter\DiskonDokterService;
use Pembayaran\V1\Rest\PembayaranTagihan\PembayaranTagihanService;
use Pembayaran\V1\Rest\PenjaminTagihan\PenjaminTagihanService;
use Pembayaran\V1\Rest\PiutangPasien\PiutangPasienService;
use Pembayaran\V1\Rest\PiutangPerusahaan\PiutangPerusahaanService;
use Pembayaran\V1\Rest\Deposit\DepositService;
use Pembayaran\V1\Rest\TagihanPendaftaran\TagihanPendaftaranService;

use Pembayaran\V1\Rest\PengembalianDeposit\PengembalianDepositService;
use General\V1\Rest\Referensi\ReferensiService;
use Cetakan\V1\Rest\KwitansiPembayaran\KwitansiPembayaranService;
use Penjualan\V1\Rest\Penjualan\PenjualanService;
use General\V1\Rest\Pasien\PasienService;

use Pembayaran\V1\Rest\SubsidiTagihan\Service as SubsidiService;
use Pembayaran\V1\Rest\Transfer\Service as transferService;

class TagihanService extends Service
{
	private $diskon;
	private $diskondokter;
	private $nontunai;
	private $penjamintagihan;
	private $piutangpasien;
	private $piutangperusahaan;
	private $deposit;
	private $pengembaliandeposit;
	private $kwitansipembayaran;
	private $penjualan;
	private $pasien;
	private $subsiditagihan;
	private $tagihanpendaftaran;
	private $transfer;
	
	protected $references = [
		'Diskon' => true,
		'DiskonDokter' => true,
		'NonTunai' => true,
		'PenjaminTagihan' => true,
		'PiutangPasien' => true,
		'PiutangPerusahaan' => true,
		'Deposit' => true,
		'PengembalianDeposit' => true,
		'KwitansiPembayaran' => true,
		'Penjualan' => true,
		'Pasien' => true,
		'SubsidiTagihan' => true,
		'TagihanPendaftaran' => true,
		'Transfer' => true
	];
    
    public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "\\Pembayaran\\V1\\Rest\\Tagihan\\TagihanEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("tagihan", "pembayaran"));
		$this->entity = new TagihanEntity();
		
		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {
			if($this->references['Diskon']) $this->diskon = new DiskonService();
			if($this->references['DiskonDokter']) $this->diskondokter = new DiskonDokterService();
			if($this->references['NonTunai']) $this->nontunai = new PembayaranTagihanService(false);
			if($this->references['PenjaminTagihan']) $this->penjamintagihan = new PenjaminTagihanService();
			if($this->references['PiutangPasien']) $this->piutangpasien = new PiutangPasienService();
			if($this->references['PiutangPerusahaan']) $this->piutangperusahaan = new PiutangPerusahaanService();
			if($this->references['Deposit']) $this->deposit = new DepositService();
			if($this->references['PengembalianDeposit']) $this->pengembaliandeposit = new PengembalianDepositService();
			if($this->references['KwitansiPembayaran']) $this->kwitansipembayaran = new KwitansiPembayaranService();			
			if($this->references['Penjualan']) $this->penjualan = new PenjualanService(true, [
				'PenjualanDetil' => true,
				'TotalTagihan' => false
			]);
			if($this->references['Pasien']) $this->pasien = new PasienService(false);
			if($this->references['SubsidiTagihan']) $this->subsiditagihan = new SubsidiService();
			if($this->references['TagihanPendaftaran']) $this->tagihanpendaftaran = new TagihanPendaftaranService(true, [
				'Tagihan' => false
			]);
			if($this->references['Transfer']) $this->transfer = new transferService(false);
		}
    }
    
	public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;
		$this->entity->exchangeArray($data);
		$this->table->insert($this->entity->getArrayCopy());
		
		return [
			'success' => true
		];
	}
	
	public function reStoreTagihan($tagihan) {
	    $adapter = $this->table->getAdapter();
	    $stmt = $adapter->query('CALL pembayaran.reStoreTagihan(?)');
	    $results = $stmt->execute([$tagihan]);
	    $results->getResource()->closeCursor();
	    return [
	        'success' => true
		];
	}

	public function hitungTotalTagihanPenjualan($tagihan) {
	    $adapter = $this->table->getAdapter();
	    $stmt = $adapter->query('CALL pembayaran.hitungTotalTagihanPenjualan(?)');
	    $results = $stmt->execute([$tagihan]);
	    $results->getResource()->closeCursor();
	    return [
	        'success' => true
		];
	}
	
	public function reDistribusiTagihan($tagihan) {
	    $adapter = $this->table->getAdapter();
	    $stmt = $adapter->query('CALL pembayaran.reProsesDistribusiTarif(?)');
	    $results = $stmt->execute([$tagihan]);
	    $results->getResource()->closeCursor();
	    return [
	        'success' => true
		];
	}

	public function getDataJumlahLamaDirawatDanVisiteDokterPerawat($tagihan) {
		$adapter = $this->table->getAdapter();
		$conn = $adapter->getDriver()->getConnection();
		$results = $conn->execute("SELECT pembayaran.getDataJumlahLamaDirawatDanVisiteDokterPerawat('".$tagihan."') INFO");
		$stmt2 = $results->getResource();
		$resultset = $stmt2->fetchAll(\PDO::FETCH_OBJ);
		$info = null;
		foreach($resultset as $data) {
			$info = $data->INFO;
		}
		return $info;
	}

	public function isTagihanTerkunci($nopen) {
		$adapter = $this->table->getAdapter();
		$conn = $adapter->getDriver()->getConnection();
		$results = $conn->execute("SELECT pembayaran.isTagihanTerkunci('".$nopen."') KUNCI");
		$stmt2 = $results->getResource();
		$resultset = $stmt2->fetchAll(\PDO::FETCH_OBJ);
		$result = false;
		foreach($resultset as $data) {
			$result = $data->KUNCI == 1;
		}
		return $result;
	}
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);

		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['Diskon']) {
					$diskon = $this->diskon->load(['TAGIHAN' => $entity['ID'], 'STATUS' => 1]);
					if(count($diskon) > 0) $entity['REFERENSI']['DISKON'] = $diskon;
				}
				
				if($this->references['DiskonDokter']) {
					$diskondokter = $this->diskondokter->load(['TAGIHAN' => $entity['ID'], 'STATUS' => 1]);
					if(count($diskondokter) > 0) $entity['REFERENSI']['DISKON_DOKTER'] = $diskondokter;
				}
				
				if($this->references['NonTunai']) {
					$result = $this->nontunai->load([
						'TAGIHAN' => $entity['ID'],
						new \Laminas\Db\Sql\Predicate\NotIn("JENIS_LAYANAN_ID", [1]),
						new \Laminas\Db\Sql\Predicate\NotIn("STATUS", [0])
					]);
					if(count($result) > 0) $entity['REFERENSI']['NON_TUNAI'] = $result;
				}

				if($this->references['PenjaminTagihan']) {
					$penjamintagihan = $this->penjamintagihan->load(['TAGIHAN' => $entity['ID']]);
					if(count($penjamintagihan) > 0) $entity['REFERENSI']['PENJAMIN_TAGIHAN'] = $penjamintagihan;
				}

				if($this->references['PiutangPasien']) {	
					$piutangpasien = $this->piutangpasien->load(['TAGIHAN' => $entity['ID'], 'STATUS' => 1]);
					if(count($piutangpasien) > 0) $entity['REFERENSI']['PIUTANG_PASIEN'] = $piutangpasien;
				}
				
				if($this->references['PiutangPerusahaan']) {
					$piutangperusahaan = $this->piutangperusahaan->load(['TAGIHAN' => $entity['ID'], 'STATUS' => 1]);
					if(count($piutangperusahaan) > 0) $entity['REFERENSI']['PIUTANG_PERUSAHAAN'] = $piutangperusahaan;
				}
				
				if($this->references['Deposit']) {
					$deposit = $this->deposit->load(['TAGIHAN' => $entity['ID'], 'STATUS' => 1]);
					if(count($deposit) > 0) $entity['REFERENSI']['DEPOSIT'] = $deposit;
				}
				
				if($this->references['PengembalianDeposit']) {
					$pengembaliandeposit = $this->pengembaliandeposit->load(['TAGIHAN' => $entity['ID'], 'STATUS' => 1]);
					if(count($pengembaliandeposit) > 0) $entity['REFERENSI']['PENGEMBALIAN_DEPOSIT'] = $pengembaliandeposit;
				}
				
				if($this->references['KwitansiPembayaran']) {
					$kwitansipembayaran = $this->kwitansipembayaran->load(['TAGIHAN' => $entity['ID'], 'TUNAI' => 1, 'start'=>0, 'limit'=>1], ['*'], ['TANGGAL DESC']);
					if(count($kwitansipembayaran) > 0) $entity['REFERENSI']['KWITANSI_PEMBAYARAN'] = $kwitansipembayaran;
				}
				
				if($this->references['Penjualan']) {
					$penjualan = $this->penjualan->load(['NOMOR' => $entity['ID']]);
					if(count($penjualan) > 0) $entity['REFERENSI']['PENJUALAN'] = $penjualan;
				}
				
				if($this->references['Pasien']) {
					if($entity['JENIS'] == 1) {
						$pasien = $this->pasien->load(['NORM' => $entity['REF']]);
						if(count($pasien) > 0) $entity['REFERENSI']['PASIEN'] = $pasien[0];
					}
				}
				
				if($this->references['SubsidiTagihan']) {
					$subsiditagihan = $this->subsiditagihan->load(['TAGIHAN' => $entity['ID']]);
					if(count($subsiditagihan) > 0) $entity['REFERENSI']['SUBSIDI_TAGIHAN'] = $subsiditagihan;
				}
				
				if($this->references['TagihanPendaftaran']) {	
					if(is_object($this->references['TagihanPendaftaran'])) {
						$references = isset($this->references['TagihanPendaftaran']->REFERENSI) ? (array) $this->references['TagihanPendaftaran']->REFERENSI : [];
						$this->tagihanpendaftaran->setReferences($references, true);
						if(isset($this->references['TagihanPendaftaran']->COLUMNS)) $this->tagihanpendaftaran->setColumns((array) $this->references['TagihanPendaftaran']->COLUMNS);
					}
					$tagihanpendaftaran = $this->tagihanpendaftaran->load(['TAGIHAN' => $entity['ID'], 'STATUS' => 1]);
					if(count($tagihanpendaftaran) > 0) $entity['REFERENSI']['TAGIHAN_PENDAFTARAN'] = $tagihanpendaftaran;
				}

				if($this->references['Transfer']){
					$transfer = $this->transfer->load(['TAGIHAN' => $entity['ID']]);
					if(count($transfer) > 0) $entity['REFERENSI']['TRANSFER'] = $transfer;
				}
			}
		}
		
		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'STATUS')) {
			$params['tagihan.STATUS'] = $params['STATUS'];
			unset($params['STATUS']);
		}

		if(!System::isNull($params, 'REF')) {
			$params['tagihan.REF'] = $params['REF'];
			unset($params['REF']);
		}

		if(isset($params['TANGGAL'])) if(!System::isNull($params, 'TANGGAL')){
			$awal = $params['TANGGAL']." 00:00:00";
			$akhir = $params['TANGGAL']." 23:59:59";
			$select->where->between("tagihan.TANGGAL", $awal, $akhir);
			unset($params['TANGGAL']);
		}
		
		if(!System::isNull($params, 'PENJAMIN') || 
			!System::isNull($params, 'JENIS_KUNJUNGAN') || 
			!System::isNull($params, 'POSISI_RUANGAN') || 
			!System::isNull($params, 'RUANGAN') || 
			!System::isNull($params, 'GROUPING')) {
			if(isset($params["JENIS"])) {
				if($params["JENIS"] == 1) { // Pasien
					$params["tagihan.JENIS"] = $params["JENIS"];
					unset($params["JENIS"]);

					$select->join(
						['tp' => new TableIdentifier('tagihan_pendaftaran', 'pembayaran')],
						new \Laminas\Db\Sql\Predicate\Expression("tp.TAGIHAN = tagihan.ID AND tp.UTAMA = 1 AND tp.STATUS = 1"),
						[]
					);

					$jenisKunjungan = 0;
					if(isset($params["JENIS_KUNJUNGAN"])) {
						$jenisKunjungan = $params["JENIS_KUNJUNGAN"];
						$params["rg.JENIS_KUNJUNGAN"] = $jenisKunjungan;
						unset($params["JENIS_KUNJUNGAN"]);
						$select->join(
							['tj' => new TableIdentifier('tujuan_pasien', 'pendaftaran')],
							"tj.NOPEN = tp.PENDAFTARAN",
							[]
						);
						$select->join(
							['rg' => new TableIdentifier('ruangan', 'master')],
							"rg.ID = tj.RUANGAN",
							[]
						);
					}

					$pos = 0;
					$ruangan = '';
					if(isset($params["POSISI_RUANGAN"])) {
						$pos = $params["POSISI_RUANGAN"];
						unset($params["POSISI_RUANGAN"]);
					}
					if(isset($params["RUANGAN"])) {
						$ruangan = $params["RUANGAN"];
						unset($params["RUANGAN"]);
					}

					if($ruangan != '') {
						if($pos == 1) { // Awal
							$select->join(
								['kj' => new TableIdentifier('kunjungan', 'pendaftaran')],
								new \Laminas\Db\Sql\Predicate\Expression("kj.NOPEN = tp.PENDAFTARAN AND kj.REF IS NULL AND kj.STATUS IN (1,2) AND kj.RUANGAN = ?", [$ruangan]),
								[]
							);
						}

						if($pos == 2) { // Akhir
							if($jenisKunjungan == 3) { // RI
								$select->join(
									['kj' => new TableIdentifier('kunjungan', 'pendaftaran')],
									new \Laminas\Db\Sql\Predicate\Expression("kj.NOPEN = tp.PENDAFTARAN AND kj.RUANGAN = ? AND kj.NOMOR = pendaftaran.getNomorKunjunganTerakhirRawatInap(kj.NOPEN)", [$ruangan]),
									[]
								);
							} else {
								$select->join(
									['kj' => new TableIdentifier('kunjungan', 'pendaftaran')],
									new \Laminas\Db\Sql\Predicate\Expression("kj.NOPEN = tp.PENDAFTARAN AND kj.REF IS NULL AND kj.STATUS IN (1,2) AND kj.RUANGAN = ?", [$ruangan]),
									[]
								);
							}
						}
					}

					if(isset($params["PENJAMIN"])) {
						$penjamin = $params['PENJAMIN'];
						$select->join(
							['pj' => new TableIdentifier('penjamin', 'pendaftaran')],
							new \Laminas\Db\Sql\Predicate\Expression("pj.JENIS = ? AND pj.NOPEN = tp.PENDAFTARAN", [$penjamin]),
							[]
						);
						unset($params['PENJAMIN']);
					}

					if(isset($params["GROUPING"])) {
						$select->join(
							['g' => new TableIdentifier('hasil_grouping', 'inacbg')],
							new \Laminas\Db\Sql\Predicate\Expression("g.NOPEN = tp.PENDAFTARAN"),
							[],
							Select::JOIN_LEFT
						);
						if($params["GROUPING"] == 1) $params["g.STATUS"] = new \Laminas\Db\Sql\Expression("g.STATUS IS NULL");
						if($params["GROUPING"] == 2) $params["g.STATUS"] = 0;
						if($params["GROUPING"] == 3) $params["g.STATUS"] = 1;
						unset($params["GROUPING"]);
					}
				}
			}
		}
	}
	
	public function getStatus($tagihan) {
		$data = $this->load(['ID' => $tagihan]);
		if(count($data) > 0) {
			return $data[0]['STATUS'];
		}
		return -1;
	}

	public function getPembayaranService() {
		return $this->nontunai;
	}
}