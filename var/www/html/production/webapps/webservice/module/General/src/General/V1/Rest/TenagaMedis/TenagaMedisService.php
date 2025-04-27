<?php
namespace General\V1\Rest\TenagaMedis;

use General\V1\Rest\Dokter\DokterService;
use General\V1\Rest\Perawat\PerawatService;
use General\V1\Rest\Pegawai\PegawaiService;
use General\V1\Rest\Referensi\ReferensiService;

class TenagaMedisService
{
	private $tenagamedis = [];
    
    public function __construct() {
		$this->tenagamedis[4] = new DokterService();	
		$this->tenagamedis[6] = new PerawatService();
		$this->pegawai = new PegawaiService();
		$this->referensi = new ReferensiService();
    }

	public function load($params = [], $columns = ['*'], $orders = []) {
		if(isset($params['JENIS'])) {
			$jenis = $params['JENIS'];
			unset($params['JENIS']);
			$referensi = $this->referensi->load(["JENIS" => 32, "ID" => $jenis]);
			$id = $referensi[0]['REF_ID'];

			if(isset($this->tenagamedis[$id])) return $this->tenagamedis[$id]->load($params, $columns, $orders);
			$params["PROFESI"] = $id;
			return $this->pegawai->load($params, $columns, $orders);
		} else return $this->pegawai->load($params, $columns, $orders);
		
		return [];
	}
}