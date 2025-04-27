<?php
namespace Layanan\V1\Rest\LayananBonSisa;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;
use Inventory\V1\Rest\Barang\BarangService;
use Layanan\V1\Rest\BonSisa\BonSisaService;

class LayananBonSisaService extends Service
{
	private $barang;

    public function __construct() {
		$this->config["entityName"] = "Layanan\\V1\\Rest\\LayananBonSisa\\LayananBonSisaEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("layanan_bon_sisa_farmasi", "layanan"));
		$this->entity = new LayananBonSisaEntity();
		
        $this->barang = new BarangService();
		$this->bon = new BonSisaService();
    }
	
	protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
		if($isCreated) {
			$bon = $this->bon->load(['bon_sisa_farmasi.ID' => $entity->get('REF')]);
			if(count($bon) > 0) {
				$sisa = $bon[0]['SISA'];
				if($sisa < $entity->get('JUMLAH')){
					return false;
				}
			}
		}
	}

	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		foreach($data as &$entity) {
            $barang = $this->barang->load(['ID' => $entity['FARMASI']]);
			if(count($barang) > 0) $entity['REFERENSI']['FARMASI'] = $barang[0];
        }
				
		return $data;
	}

    protected function queryCallback(Select &$select, &$params, $columns, $orders) {
        if(!System::isNull($params, 'BON')) { 
			$select->where(["REF" => $params['BON']]);
			unset($params['BON']);
		}
        if(!System::isNull($params, 'STATUS')) { 
			$select->where(["STATUS" => $params['STATUS']]);
			unset($params['STATUS']);
		}
	}
	public function getValidasiStokOpname($ref,$tanggal) {
		$ruangan = $this->getRuangan($ref);
		$periodeSo = $this->resource->getPeriodeAkhirSoRuangan($ruangan);
		if($periodeSo >= $tanggal) {
			return [
				'success' => false,
				'message' => "Periode Stok Opname Sudah Selesai, Tidak Dapat Melakukan Transaksi Di Bawah Periode Stok Opname"
			];
		}
		return [
			'success' => true
		];
	}
	private function getRuangan($ref) {
		$result = false;
		$result = $this->execute("SELECT k.RUANGAN FROM layanan.bon_sisa_farmasi b, layanan.farmasi f, pendaftaran.kunjungan k WHERE k.NOMOR = f.KUNJUNGAN AND f.ID = b.REF AND b.ID = ?", [$ref]);
		if(count($result) > 0) {
			return $result[0]["RUANGAN"];
		}
		return 0;
	}
	public function isNotValidateQty($data) {
		$result = false;
		if(isset($data->BON_DETIL)) {
			foreach($data->BON_DETIL as $dtl) {
				$bon = $dtl['REF'];
				$jumlah = $dtl['JUMLAH'];
				$result = $this->execute("SELECT SISA FROM layanan.bon_sisa_farmasi WHERE ID = ?", [$bon]);
				if(count($result) > 0) {
					if($result[0]["SISA"] < $jumlah) {
						return [
							'success' => false,
							'message' => "Terdapat Item Barang yang Jumlah layanan Lebih Besar Dari Sisa BON"
						];
						break;
					}
				}
			}
		}
		return [
			'success' => true
		];
	}
	public function isNotValidateStok($data) {
		$result = false;
		if(isset($data->BON_DETIL)) {
			$isValidate = $this->resource->getPropertyConfig(73) == 'TRUE';
			if($isValidate) {
				foreach($data->BON_DETIL as $dtl) {
					$barang = $dtl['FARMASI'];
					$ruangan = $this->getRuangan($dtl['REF']);
					$jumlah = $dtl['JUMLAH'];
					$result = $this->execute("SELECT SUM(br.STOK) STOKRS, b.NAMA FROM inventory.barang_ruangan br, inventory.barang b WHERE b.ID = br.BARANG AND br.BARANG = ? AND br.RUANGAN = ?", [$barang,$ruangan]);
					
					if(count($result) > 0) {
						if($result[0]["STOKRS"] < $jumlah) {
							return [
								'success' => false,
								'message' => "Terdapat Item Barang yang Jumlah Layanan Lebih Besar Dari Jumlah STOK Ruangan yang tersedia ( ".$result[0]["NAMA"]." | STOK : ".$result[0]["STOKRS"].")"
							];
							break;
						}
					}
				}
			}
		}
		return [
			'success' => true
		];
	}
}
