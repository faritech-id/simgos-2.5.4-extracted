<?php
namespace Inventory\V1\Rest\Barang;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;

use Inventory\V1\Rest\Kategori\KategoriService;
use Inventory\V1\Rest\HargaBarang\HargaBarangService;
use Inventory\V1\Rest\Penyedia\PenyediaService;
use Inventory\V1\Rest\Satuan\SatuanService;
use General\V1\Rest\Referensi\ReferensiService;
use Inventory\V1\Rest\PenggolonganBarang\Service as penggolonganService;
class BarangService extends Service
{
	private $kategori;
    private $penyedia;
	private $satuan;
	private $hargaBarang;
    private $referensi;
	private $penggolongan;
	
    public function __construct() {
		$this->config["entityName"] = "\\Inventory\\V1\\Rest\\Barang\\BarangEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("barang", "inventory"));
		$this->entity = new BarangEntity();
		
		$this->kategori = new KategoriService();
        $this->penyedia = new PenyediaService();
		$this->satuan = new SatuanService();
		$this->hargaBarang = new HargaBarangService(false);
        $this->referensi = new ReferensiService();
		$this->penggolongan = new penggolonganService();
    }
	
	protected function onAfterSaveCallback($id, $data) {
		/* Simpan penggolongan barang */
		if(isset($data["PENGGOLONGAN"])){
			foreach($data['PENGGOLONGAN'] as $dtl) {
				$dtl['BARANG'] = ($dtl['BARANG'] == 0) ? $id : ($dtl['BARANG'] != $id ? $id : $dtl['BARANG']) ;
				$idpgol = (int)$dtl['ID'];
				$this->penggolongan->simpanData($dtl, $idpgol == 0);
			}
		}
	}
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		foreach($data as &$entity) {
			$entity['REFERENSI']['KATEGORI']['NAMA'] = '-';
			$entity['REFERENSI']['PENYEDIA']['NAMA'] = '-';
			$entity['REFERENSI']['SATUAN']['NAMA'] = '-';
			$entity['REFERENSI']['GENERIK']['DESKRIPSI'] = '-';
			$entity['REFERENSI']['MERK']['DESKRIPSI'] = '-';
			$kategori = $this->kategori->load(['ID' => $entity['KATEGORI']]);
			if(count($kategori) > 0) $entity['REFERENSI']['KATEGORI'] = $kategori[0];
            $penyedia = $this->penyedia->load(['ID' => $entity['PENYEDIA']]);
			if(count($penyedia) > 0) $entity['REFERENSI']['PENYEDIA'] = $penyedia[0];
			$satuan = $this->satuan->load(['ID' => $entity['SATUAN']]);
			if(count($satuan) > 0) $entity['REFERENSI']['SATUAN'] = $satuan[0];
			$hargaBarang = $this->hargaBarang->load(['BARANG' => $entity['ID'], 'STATUS' => 1]);
			if(count($hargaBarang) > 0) $entity['REFERENSI']['HARGA'] = $hargaBarang[0];
            $referensi = $this->referensi->load(['JENIS' => 42, 'ID' => $entity['GENERIK']]);
			if(count($referensi) > 0) $entity['REFERENSI']['GENERIK'] = $referensi[0];
            $referensi = $this->referensi->load(['JENIS' => 39, 'ID' => $entity['MERK']]);
			if(count($referensi) > 0) $entity['REFERENSI']['MERK'] = $referensi[0];
		}
				
		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'QUERY')) { 
			$select->where->like('NAMA', '%'.$params['QUERY'].'%');
			unset($params['QUERY']);
		}
		if(!System::isNull($params, 'KATEGORI')) { 
			$select->where->like('KATEGORI', '%'.$params['KATEGORI'].'%');
			unset($params['KATEGORI']);
		}
	}
}
