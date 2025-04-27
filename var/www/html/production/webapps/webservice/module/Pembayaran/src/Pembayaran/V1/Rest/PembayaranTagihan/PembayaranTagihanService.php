<?php
namespace Pembayaran\V1\Rest\PembayaranTagihan;

use DBService\DatabaseService;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;
use Laminas\Db\Sql\TableIdentifier;

use Pembayaran\V1\Rest\Tagihan\TagihanService;
use Pembayaran\V1\Rest\Penyedia\Service as PenyediaService;
use General\V1\Rest\Referensi\ReferensiService;
use General\V1\Rest\Rekening\Service as RekeningService;
use Aplikasi\V1\Rest\Pengguna\PenggunaService;
use Cetakan\V1\Rest\KwitansiPembayaran\KwitansiPembayaranService;

class PembayaranTagihanService extends Service
{
	private $tagihan;
	private $referensi;
	private $peyedia;
	private $rekening;
	private $kasir;
	private $kwitansipembayaran;

	protected $references = [
		'Tagihan' => true,
		'JenisLayanan' => true,
		'Penyedia' => true,
		'Rekening' => true,
		'JenisKartu' => true,
		'Bank' => true,
		'Kasir' => true,
		'KwitansiPembayaran' => true,
	];

    public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "Pembayaran\\V1\\Rest\\PembayaranTagihan\\PembayaranTagihanEntity";
        $this->config["entityId"] = "NOMOR";
	    $this->config["autoIncrement"] = false;
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("pembayaran_tagihan", "pembayaran"));
		$this->entity = new PembayaranTagihanEntity();

		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {
			$this->referensi = new ReferensiService();
			if($this->references['Tagihan']) $this->tagihan = new TagihanService(true, [
				'Diskon' => false,
				'DiskonDokter' => false,
				'NonTunai' => false,
				'PenjaminTagihan' => false,
				'PiutangPasien' => false,
				'PiutangPerusahaan' => false,
				'Deposit' => false,
				'PengembalianDeposit' => false,
				'KwitansiPembayaran' => false,
				'Penjualan' => false,
				'Pasien' => true,
				'SubsidiTagihan' => false,
				'TagihanPendaftaran' => false,
				'Transfer' => false
			]);
			if($this->references['Penyedia']) $this->peyedia = new PenyediaService();
			if($this->references['Rekening']) $this->rekening = new RekeningService();
			if($this->references['Kasir']) $this->kasir = new PenggunaService();
			if($this->references['KwitansiPembayaran']) $this->kwitansipembayaran = new KwitansiPembayaranService();
		}
    }

	protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
		if($isCreated) {
			if(empty($data["TANGGAL"])) $entity->set("TANGGAL", new \Laminas\Db\Sql\Expression('NOW()'));
			$entity->set("NOMOR", $this->generateNomor());
		}
	}

	public function generateNomor() {
        $adapter = $this->table->getAdapter();
		$conn = $adapter->getDriver()->getConnection();
	    $result = $conn->execute("SELECT generator.generateNoPembayaran(DATE(NOW())) NOMOR");
        $data = $result->current();
        return $data["NOMOR"];
    }

	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);

		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['Tagihan']) {
					$result = $this->tagihan->load(['ID' => $entity['TAGIHAN']]);
					if(count($result) > 0) $entity['REFERENSI']['TAGIHAN'] = $result[0];
				}
				if($this->references['JenisLayanan']) {
					$result = $this->referensi->load(['JENIS' => 172, 'ID' => $entity['JENIS_LAYANAN_ID']]);
					if(count($result) > 0) $entity['REFERENSI']['JENIS_LAYANAN'] = $result[0];
				}
				if($this->references['Penyedia'] && !empty($entity['PENYEDIA_ID'])) {
					$result = $this->peyedia->load(['ID' => $entity['PENYEDIA_ID']]);
					if(count($result) > 0) $entity['REFERENSI']['PENYEDIA'] = $result[0];
				}
				if($this->references['Rekening'] && !empty($entity['REKENING_ID'])) {
					$result = $this->rekening->load(['ID' => $entity['REKENING_ID']]);
					if(count($result) > 0) $entity['REFERENSI']['REKENING'] = $result[0];
				}
				if($this->references['JenisKartu'] && !empty($entity['JENIS_KARTU_ID'])) {
					$result = $this->referensi->load(['JENIS' => 17, 'ID' => $entity['JENIS_KARTU_ID']]);
					if(count($result) > 0) $entity['REFERENSI']['JENIS_KARTU'] = $result[0];
				}
				if($this->references['Bank'] && !empty($entity['BANK_ID'])) {
					$result = $this->referensi->load(['JENIS' => 16, 'ID' => $entity['BANK_ID']]);
					if(count($result) > 0) $entity['REFERENSI']['BANK'] = $result[0];
				}
				if($this->references['Kasir'] && !empty($entity['OLEH'])) {
					$result = $this->kasir->load(['ID' => $entity['OLEH']], ["NIP", "NAMA", "JENIS"]);
					if(count($result) > 0) $entity['REFERENSI']['KASIR'] = $result[0];
				}
				if($this->references['KwitansiPembayaran']) {
					$tunai = $entity['JENIS_LAYANAN_ID'] == 1 ? 1 : 0;
					$kwitansipembayaran = $this->kwitansipembayaran->load(['TAGIHAN' => $entity['TAGIHAN'], 'TUNAI' => $tunai, 'JENIS_LAYANAN_ID' => $entity['JENIS_LAYANAN_ID'], 'start'=>0, 'limit'=>1], ['*'], ['TANGGAL DESC']);
					if(count($kwitansipembayaran) > 0) $entity['REFERENSI']['KWITANSI_PEMBAYARAN'] = $kwitansipembayaran[0];
				}
			}
		}
		
		return $data;
	}
	
	public function masihAdaKunjunganBlmFinal($id) {
		$adapter = $this->table->getAdapter();
		$conn = $adapter->getDriver()->getConnection();
		$results = $conn->execute("CALL pembayaran.masihAdaKunjunganBlmFinal('".$id."')");
		$stmt2 = $results->getResource();
		$resultset = $stmt2->fetchAll(\PDO::FETCH_OBJ);
		$found = false;
		foreach($resultset as $data) {
			$found .= $data->RUANGAN."<br/>";
		}
		return $found;
	}
	
	public function masihAdaOrderKonsulMutasiYgBlmDiterima($id) {
		$adapter = $this->table->getAdapter();
		$conn = $adapter->getDriver()->getConnection();
		$results = $conn->execute("CALL pembayaran.masihAdaOrderKonsulMutasiYgBlmDiterima('".$id."')");
		$stmt2 = $results->getResource();
		$resultset = $stmt2->fetchAll(\PDO::FETCH_OBJ);
		$found = false;
		foreach($resultset as $data) {
			$found .= $data->DESKRIPSI."<br/>";
		}
		return $found;
	}
	
	public function getTanggalTerakhirPembayaran($tagihan, $jenis) {
		$adapter = $this->table->getAdapter();
		$conn = $adapter->getDriver()->getConnection();
		$results = $conn->execute("SELECT pembayaran.getTanggalTerakhirPembayaran('".$tagihan."', ".$jenis.") TANGGAL");
		$stmt2 = $results->getResource();
		$resultset = $stmt2->fetchAll(\PDO::FETCH_OBJ);
		$tanggal = null;
		foreach($resultset as $data) {
			$tanggal = $data->TANGGAL;
		}
		return $tanggal;
	}

	public function isTagihanPendaftaranTerpisah($tagihan) {
		$adapter = $this->table->getAdapter();
		$conn = $adapter->getDriver()->getConnection();
		$results = $conn->execute("SELECT pembayaran.isTagihanPendaftaranTerpisah('".$tagihan."') TERPISAH");
		$stmt2 = $results->getResource();
		$resultset = $stmt2->fetchAll(\PDO::FETCH_OBJ);
		$terpisah = false;
		foreach($resultset as $data) {
			$terpisah = ($data->TERPISAH == 1);
		}
		return $terpisah;
	}
}
