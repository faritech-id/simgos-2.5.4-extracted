<?php
namespace Layanan\V1\Rest\PetugasTindakanMedis;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;
use General\V1\Rest\Referensi\ReferensiService;
use General\V1\Rest\TenagaMedis\TenagaMedisService;
use Laminas\Db\Sql\Select;
use DBService\System;

class PetugasTindakanMedisService extends Service
{
	private $referensi;
	private $tenagamedis;
	
    public function __construct() {
		$this->config["entityName"] = "Layanan\\V1\\Rest\\PetugasTindakanMedis\\PetugasTindakanMedisEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("petugas_tindakan_medis", "layanan"));
		$this->entity = new PetugasTindakanMedisEntity();
		
		$this->referensi = new ReferensiService();
		$this->tenagamedis = new TenagaMedisService();
    }
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		foreach($data as &$entity) {		
			$referensi = $this->referensi->load(['JENIS' => 32,'ID' => $entity['JENIS']]);
			if(count($referensi) > 0) $entity['REFERENSI']['JENIS'] = $referensi[0];
			
			$tenagamedis = $this->tenagamedis->load(['JENIS' => $entity['JENIS'],'ID' => $entity['MEDIS']]);
			if(count($tenagamedis) > 0) $entity['REFERENSI']['MEDIS'] = $tenagamedis[0];
		}
		
		return $data;
	}
        
	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(isset($params['KUNJUNGAN'])) {
			$select->join(
				['tm' => new TableIdentifier('tindakan_medis', 'layanan')],
				"tm.ID = petugas_tindakan_medis.TINDAKAN_MEDIS",
				isset($params['SHOW_TINDAKAN_JASA']) ? ["TANGGAL_TINDAKAN" => "TANGGAL"] : []
			);
			$select->join(
				['t' => new TableIdentifier('tindakan', 'master')],
				"t.ID = tm.TINDAKAN",
				isset($params['SHOW_TINDAKAN_JASA']) ? ["NAMA_TINDAKAN" => "NAMA"] : []
			);
			$select->join(
				['rt' => new TableIdentifier('rincian_tagihan', 'pembayaran')],
				"rt.REF_ID = tm.ID",
				[]
			);
			$select->join(
				['tt' => new TableIdentifier('tarif_tindakan', 'master')],
				"tt.ID = rt.TARIF_ID",
				[new \Laminas\Db\Sql\Expression('DOKTER_OPERATOR')]
			);
			$select->where("tm.KUNJUNGAN = '".$params['KUNJUNGAN']."' AND tm.STATUS = 1 AND rt.JENIS = 3");
			unset($params['KUNJUNGAN']);
			unset($params['SHOW_TINDAKAN_JASA']);
		}
		if(isset($params['DOKTER'])) {
			$select->join(
				['d' => new TableIdentifier('dokter', 'master')],
				"d.ID = petugas_tindakan_medis.MEDIS",
				[]
			);
			$select->join(
				['p' => new TableIdentifier('pegawai', 'master')],
				"p.NIP = d.NIP",
				[]
			);
			$select->where("petugas_tindakan_medis.JENIS IN (1, 2) AND p.NAMA LIKE '%".$params['DOKTER']."%'");
			unset($params['DOKTER']);
		}
	}
}