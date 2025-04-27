<?php
namespace Layanan\V1\Rest\PemakaianBhp;
use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;
use DBService\generator\Generator;

use General\V1\Rest\Ruangan\RuanganService;
use Layanan\V1\Rest\PemakaianBhpDetil\PemakaianBhpDetilService;

class PemakaianBhpService extends Service
{
	private $asal;
	private $pemakaiandetil;
	
    public function __construct() {
		$this->config["entityName"] = "Layanan\\V1\Rest\PemakaianBhp\PemakaianBhpEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("pemakaian_bhp", "layanan"));
		$this->entity = new PemakaianBhpEntity();
		$this->pemakaiandetil = new PemakaianBhpDetilService();
		$this->asal = new RuanganService();
    }
	
	protected function onAfterSaveCallback($id, $data) {
		$status = !empty($data['STATUS']) ? $data['STATUS'] : 1;
		if(isset($data['PEMAKAIAN_DETIL'])) $this->SimpanDetilPemakaian($data, $id, $status);
	}
	
	private function SimpanDetilPemakaian($data, $id, $status) {
		if(isset($data['PEMAKAIAN_DETIL'])) {
			foreach($data['PEMAKAIAN_DETIL'] as $dtl) {
				$dtl['PEMAKAIAN'] = $id;
				$dtl['STATUS'] = $status;
				$this->pemakaiandetil->simpan($dtl);
			}
		}
	}
	
	public function load($params = [], $columns = ['*'], $pemakaians = []) {
		$data = parent::load($params, $columns, $pemakaians);
		
		foreach($data as &$entity) {			
			$asal = $this->asal->load(['ID' => $entity['RUANGAN']]);
			if(count($asal) > 0) $entity['REFERENSI']['RUANGAN'] = $asal[0];			
		}
		
		return $data;
	}
	
	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'RUANGAN')) { 
			$select->where(["RUANGAN" => $params['RUANGAN']]);
			unset($params['RUANGAN']);
		}
		
		if(!System::isNull($params, 'KUNJUNGAN')) { 
			$select->where(["KUNJUNGAN" => $params['KUNJUNGAN']]);
			unset($params['KUNJUNGAN']);
		}
		if(!System::isNull($params, 'STATUS')) { 
			$select->where(["STATUS" => $params['STATUS']]);
			unset($params['STATUS']);
		}
	}

	public function getValidasiStokOpname($nomor) {
		$adapter = $this->table->getAdapter();
		$stmt = $adapter->query("SELECT TANGGAL,RUANGAN FROM layanan.pemakaian_bhp WHERE ID = $nomor");
		$rst = $stmt->execute();
		$row = $rst->current();
		$tglTransaksi=$row["TANGGAL"];
		$idRuangan=$row["RUANGAN"];
		$periodeSo = $this->getPeriodeStokOpname($idRuangan);
		if($periodeSo > $tglTransaksi) {
			return [
				'success' => false,
				'message' => "Periode Stok Opname Sudah Selesai, Tidak Dapat Melakukan Transaksi Di Bawah Periode Stok Opname"
			];
		}
		return [
			'success' => true
		];
	}
	
	public function getValidasiStokOpnameNew($ruangan,$tanggal) {
		$adapter = $this->table->getAdapter();
		$periodeSo = $this->getPeriodeStokOpname($ruangan);
		if($periodeSo > $tanggal) {
			return [
				'success' => false,
				'message' => "Periode Stok Opname Sudah Selesai, Tidak Dapat Melakukan Transaksi Di Bawah Periode Stok Opname"
			];
		}
		return [
			'success' => true
		];
	}
	private function getPeriodeStokOpname($ruangan) {
		$adapter = $this->table->getAdapter();
	    $stmt = $adapter->query("SELECT COUNT(*) ROWSO, IF(so.TANGGAL IS NULL, DATE_FORMAT('0000-00-00','%Y-%m-%d 23:59:59'), DATE_FORMAT(MAX(so.TANGGAL),'%Y-%m-%d 23:59:59')) PERIODE FROM inventory.stok_opname so WHERE so.RUANGAN = '$ruangan' AND so.STATUS = 'Final' ORDER BY so.TANGGAL DESC LIMIT 1");
	    $rst = $stmt->execute();
	    $row = $rst->current();
	    
	    return $row['PERIODE'];
	}
	public function isNotValidateStok($data) {
		$result = false;
		if(isset($data->PEMAKAIAN_DETIL)) {
			$isValidate = $this->resource->getPropertyConfig(72) == 'TRUE';
			if($isValidate) {
				foreach($data->PEMAKAIAN_DETIL as $dtl) {
					$barang = $dtl['BARANG'];
					$ruangan = $dtl['RUANGAN'];
					$jumlah = $dtl['JUMLAH'];
					$result = $this->execute("SELECT SUM(br.STOK) STOKRS, b.NAMA FROM inventory.barang_ruangan br, inventory.barang b WHERE b.ID = br.BARANG AND br.BARANG = ? AND br.RUANGAN = ?", [$barang,$ruangan]);
					
					if(count($result) > 0) {
						if($result[0]["STOKRS"] < $jumlah) {
							return [
								'success' => true,
								'message' => "Terdapat Item Barang yang Jumlah pemakaian Lebih Besar Dari Jumlah STOK Ruangan ( ".$result[0]["NAMA"]." )"
							];
							break;
						}
					}
				}
			}
			return [
				'success' => false
			];
		}
	}
}
