<?php
namespace Layanan\V1\Rest\OrderDetilResep;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;
use Laminas\Db\Sql\Select;
use Laminas\Db\Sql\Expression;
use DBService\System;
use General\V1\Rest\Referensi\ReferensiService;
use General\V1\Rest\FrekuensiAturanResep\FrekuensiAturanResepService;
use Inventory\V1\Rest\Barang\BarangService;
use Inventory\V1\Rest\HargaBarang\HargaBarangService;

class OrderDetilResepService extends Service
{
	private $tindakan;
	private $referensi;
	private $barang;
	private $hargabarang;
	private $frekuensi;

    public function __construct() {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("order_detil_resep", "layanan"));
		$this->entity = new OrderDetilResepEntity();
		$this->referensi = new ReferensiService();
		$this->barang = new BarangService();
		$this->hargabarang = new HargaBarangService();
		$this->frekuensi = new FrekuensiAturanResepService();
    }
        
	public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;
		$this->entity->exchangeArray($data);
		
		$order_id = $this->entity->get('ORDER_ID');
		$farmasi = $this->entity->get('FARMASI');		
		$aturan = $this->entity->get('ATURAN_PAKAI');
		$groupracikan = $this->entity->get('GROUP_RACIKAN') ? $this->entity->get('GROUP_RACIKAN') : 0;
		$cek = $this->table->select(["ORDER_ID" => $order_id, "FARMASI" => $farmasi, "GROUP_RACIKAN"=> $groupracikan])->toArray();
		if(count($cek) > 0) {
			$_data = $this->entity->getArrayCopy();
			$this->table->update($_data, ["ORDER_ID" => $order_id, "FARMASI" => $farmasi]);
		} else {
			$this->entity->set('TANGGAL_STOP', null);
			$this->entity->set('USER_STOP', null);
			$_data = $this->entity->getArrayCopy();
			$this->table->insert($_data);
		}
		
		return $this->load(['order_detil_resep.ORDER_ID' => $order_id]);
	}

	public function stoporder($data) {
		$data = is_array($data) ? $data : (array) $data;
		$this->entity->exchangeArray($data);
		$order_id = $this->entity->get('ORDER_ID');
		$farmasi = $this->entity->get('FARMASI');
		$cek = $this->table->select(["ORDER_ID" => $order_id, "FARMASI" => $farmasi])->toArray();
		if(count($cek) > 0) {
			$_data = $this->entity->getArrayCopy();
			$this->table->update($_data, ["ORDER_ID" => $order_id, "FARMASI" => $farmasi]);
		}
		return true;
	}
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		$adapter = $this->table->getAdapter();
		foreach($data as &$entity) {
			$isId = is_numeric($entity['ATURAN_PAKAI']) ? $entity['ATURAN_PAKAI'] : false;
			if($isId) {
				$aturan = $this->referensi->load(['ID' => $entity['ATURAN_PAKAI'], 'JENIS'=>41]);
				if(count($aturan) > 0) $entity['REFERENSI']['ATURAN_PAKAI'] = $aturan[0];
			}
			
			$jenisresep = $this->referensi->load(['ID' => $entity['RACIKAN'], 'JENIS'=>47]);
			if(count($jenisresep) > 0) $entity['REFERENSI']['RACIKAN'] = $jenisresep[0];
			
			$farmasi = $this->barang->load(['ID' => $entity['FARMASI']]);
			if(count($farmasi) > 0) $entity['REFERENSI']['FARMASI'] = $farmasi[0];
			
			$hargabarang = $this->hargabarang->load(['BARANG' => $entity['FARMASI'], "STATUS" => 1]);
			if(count($hargabarang) > 0) $entity['REFERENSI']['HARGA_BARANG'] = $hargabarang[0];
			
			$petunjuk = $this->referensi->load(array('ID' => $entity['PETUNJUK_RACIKAN'], 'JENIS'=>84));
			if(count($petunjuk) > 0) $entity['REFERENSI']['PETUNJUK_RACIKAN'] = $petunjuk[0];

			$frekuensi = $this->frekuensi->load(array('ID' => $entity['FREKUENSI']));
			if(count($frekuensi) > 0) $entity['REFERENSI']['FREKUENSI'] = $frekuensi[0];

			$rute = $this->referensi->load(array('ID' => $entity['RUTE_PEMBERIAN'], 'JENIS' => 217));
			if(count($rute) > 0) $entity['REFERENSI']['RUTE_PEMBERIAN'] = $rute[0];

			$statuspemeberian = $this->referensi->load(array('ID' => $entity['STATUS_PEMBERIAN'], 'JENIS' => 218));
			if(count($statuspemeberian) > 0) $entity['REFERENSI']['STATUS_PEMBERIAN'] = $statuspemeberian[0];

			$result = $this->execute("SELECT br.STOK FROM layanan.order_resep o, inventory.barang_ruangan br
			WHERE br.RUANGAN = o.TUJUAN AND br.BARANG = ? AND o.NOMOR = ?", [$entity['FARMASI'],$entity['ORDER_ID']]);
			if(count($result) > 0) {
				$entity['REFERENSI']['STOK_RUANGAN'] = $result[0]['STOK'];
			} else {
				$entity['REFERENSI']['STOK_RUANGAN'] = 0;
			}
			
		}
		
		return $data;
	}
	
	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		$norm = isset($params['NORM']) ? $params['NORM'] : '';
		
		if($norm != ''){
			$select->join(['d' => new TableIdentifier("order_resep", "layanan")], "order_detil_resep.ORDER_ID = d.NOMOR", ['TANGGAL']);
			$select->join(['k' => new TableIdentifier("kunjungan", "pendaftaran")], "d.KUNJUNGAN = k.NOMOR", []);
			$select->join(['p' => new TableIdentifier("pendaftaran", "pendaftaran")], "k.NOPEN = p.NOMOR", []);
			$select->join(['ra' => new TableIdentifier("ruangan", "master")], "k.RUANGAN = ra.ID", ['RUANGAN_ASAL' => 'DESKRIPSI']);
			$select->join(['rt' => new TableIdentifier("ruangan", "master")], "d.TUJUAN = rt.ID", ['RUANGAN_TUJUAN' => 'DESKRIPSI']);
			$select->order("d.TANGGAL DESC");
		}
		
		if(isset($params['NOPEN'])) {
			if(!System::isNull($params, 'NOPEN')) {
				$select->join(['d' => new TableIdentifier("order_resep", "layanan")], "order_detil_resep.ORDER_ID = d.NOMOR", ['TANGGAL']);
				$select->join(['k' => new TableIdentifier("kunjungan", "pendaftaran")], "d.KUNJUNGAN = k.NOMOR", []);
				$select->join(['p' => new TableIdentifier("pendaftaran", "pendaftaran")], "k.NOPEN = p.NOMOR", []);
				$select->where("(p.NOMOR = '".$params['NOPEN']."')");
				unset($params['NOPEN']);
			}
		}
	}
}