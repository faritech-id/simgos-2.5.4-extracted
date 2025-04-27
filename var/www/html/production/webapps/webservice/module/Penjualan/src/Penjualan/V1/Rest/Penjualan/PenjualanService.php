<?php
namespace Penjualan\V1\Rest\Penjualan;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\generator\Generator;
use Zend\json\Json;
use DBService\System;
use DBService\Service;

use Penjualan\V1\Rest\PenjualanDetil\PenjualanDetilService;
use Pembayaran\V1\Rest\Tagihan\TagihanService;

class PenjualanService extends Service
{
	private $penjualandetil;
	private $totaltagihan;
	
	protected $references = array(
		'PenjualanDetil' => true,
		'TotalTagihan' => true
	);
	
     public function __construct($includeReferences = true, $references = array()) {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("penjualan", "penjualan"));
		$this->entity = new PenjualanEntity();
		
		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		if($includeReferences) {			
			if($this->references['PenjualanDetil']) $this->penjualandetil = new PenjualanDetilService();
			if($this->references['TotalTagihan']) $this->totaltagihan = new TagihanService();
		}
		
		
    }
	
	public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;
		$this->entity->exchangeArray($data);
		
		$nomor = is_numeric($this->entity->get('NOMOR')) ? $this->entity->get('NOMOR') : false;
		$this->entity->set('TANGGAL', new \Laminas\Db\Sql\Expression('NOW()'));
		
		if($nomor) {
			$_data = $this->entity->getArrayCopy();
			$this->table->update($_data, array("NOMOR" => $nomor));
		} else {
			$nomor = Generator::generateNoTagihan();
			$this->entity->set('NOMOR', $nomor);
			$_data = $this->entity->getArrayCopy();
			$this->table->insert($_data);
		}
		
		$this->SimpanDetilPenjualan($data, $nomor);
		$this->SimpanTagihanPenjualan($data, $nomor);
		
		return $this->load(array('penjualan.NOMOR' => $nomor));
	}
	
	private function SimpanDetilPenjualan($data, $id) {
		if(isset($data['PENJUALAN_DETIL'])) {
			
			foreach($data['PENJUALAN_DETIL'] as $dtl) {
				$dtl['PPN'] = $data['PPN'];
				$dtl['PENJUALAN_ID'] = $id;
				$this->penjualandetil->simpan($dtl);
			}
		}
	}
	
	private function SimpanTagihanPenjualan($data, $id) {
		if(isset($data['TOTAL_PENJUALAN'])) {
			foreach($data['TOTAL_PENJUALAN'] as $dtl) {
				$dtl['ID'] = $id;
				$this->totaltagihan->simpan($dtl);
			}
		}
	}

	public function getValidasiStokBarangRuangan($data) {
		$adapter = $this->table->getAdapter();
		if(isset($data->PENJUALAN_DETIL)) {
			foreach($data->PENJUALAN_DETIL as $dtl) {
				$barang = $dtl['BARANG'];
				$jml = $dtl['JUMLAH'];
				$ruangan = $dtl['RUANGAN'];
				$stmt = $adapter->query("SELECT br.STOK FROM inventory.barang_ruangan br WHERE br.RUANGAN = '$ruangan' AND br.BARANG = $barang AND STATUS = 1");
				$rst = $stmt->execute();
				$data = $rst->current();
				if(count($data)> 0) {
					if($data['STOK'] < $jml){
						return array(
							'success' => false,
							'message' => "Stok Barang Lebih Kecil Dari Jumlah"
						);
					}
				} else {
					return array(
						'success' => false,
						'message' => "Barang Tidak Termapping Ke Ruangan Pengirim"
					);
				}
			}
			return array(
				'success' => true
			);
		}
	}
}