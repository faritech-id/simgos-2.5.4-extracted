<?php
namespace General\V1\Rest\Pegawai;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;

use General\V1\Rest\Referensi\ReferensiService;
use Pegawai\V1\Rest\KartuIdentitas\Service as KartuIdentitasService;
use Pegawai\V1\Rest\KontakPegawai\KontakPegawaiService;

class PegawaiService extends Service
{
	private $referensi;
	private $kartuidentitas;
	private $kontak;
	
	public function __construct() {
		$this->config["entityName"] = "General\\V1\\Rest\\Pegawai\\PegawaiEntity";
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("pegawai", "master"));
		$this->entity = new PegawaiEntity();
		
		$this->referensi = new ReferensiService();
		$this->kartuidentitas = new KartuIdentitasService();
		$this->kontak = new KontakPegawaiService();
    }

	protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
		if(isset($data['NIP_BARU'])) {
			$this->entity->set('NIP', $data['NIP_BARU']);
		}
	}
	protected function onAfterSaveCallback($id, $data) {
		$this->simpanKIP($data);
	}
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		
		foreach($data as &$entity) {
			if(isset($entity['PROFESI'])) {
				$profesi = $this->referensi->load(['JENIS' => 36,'ID' => $entity['PROFESI']]);
				if(count($profesi) > 0) $entity['REFERENSI']['PROFESI'] = $profesi[0];
			}
			if(isset($entity['AGAMA'])) {
				$agama = $this->referensi->load(['JENIS' => 1,'ID' => $entity['AGAMA']]);
				if(count($agama) > 0) $entity['REFERENSI']['AGAMA'] = $agama[0];
			}
			if(isset($entity['NIP'])) {
				$kartuidentitas = $this->kartuidentitas->load(['NIP' => $entity['NIP']]);
				if(count($kartuidentitas) > 0) $entity['KARTU_IDENTITAS'] = $kartuidentitas;

				$kontak = $this->kontak->load(['NIP' => $entity['NIP'], "STATUS" => 1]);
				if(count($kontak) > 0) $entity['KONTAKS'] = $kontak;
			}
		}
		
		
		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(isset($params['NAMA'])) {
			if(!System::isNull($params, 'NAMA')) {
				$select->where->like('NAMA', '%'.$params['NAMA'].'%');
				unset($params['NAMA']);
			}
		}
		if(isset($params['ALAMAT'])) {
			if(!System::isNull($params, 'ALAMAT')) {
				$select->where->like('ALAMAT', $params['ALAMAT'].'%');
				unset($params['ALAMAT']);
			}
		}
		if(isset($params['TANGGAL_LAHIR'])) {
			if(!System::isNull($params, 'TANGGAL_LAHIR')) {
				$select->where->equalTo('TANGGAL_LAHIR', substr($params['TANGGAL_LAHIR'],0,10));
				unset($params['TANGGAL_LAHIR']);
			}
		}
		if(isset($params['QUERY'])) if(!System::isNull($params, 'QUERY')) {
			$params[] = new \Laminas\Db\Sql\Predicate\Expression("(NIP LIKE ? OR NAMA LIKE ?)", ["%".$params["QUERY"]."%", "%".$params["QUERY"]."%"]);
			unset($params['QUERY']);
		}
		if(isset($params['IDX'])) {
			if(!System::isNull($params, 'IDX')) {
				$select->where(["ID" => $params["IDX"]]);
				unset($params['IDX']);
			}
		}
	}
	
	private function simpanKIP($data) {
		if(isset($data['KARTU_IDENTITAS'])) {
			foreach($data['KARTU_IDENTITAS'] as $kartu) {
				$created = true;
				if(!empty($kartu["ID"])) {
					$created = false;
				}
				if($created) {
					$nip = (isset($data["NIP"]) ? $data["NIP"] : (isset($kartu["NIP"]) ? $kartu["NIP"] : null));
					if($nip) {
						$cek = $this->kartuidentitas->load(['NIP' => $nip]);
						if(count($cek) > 0) {
							$created = false;
							$kartu['ID'] = $cek[0]['ID'];
						}
					}
				}
				$this->kartuidentitas->simpanData($kartu, $created); 
			}
		}
	}

	public function isPPA($nip) {
		$pegawai = $this->load(["NIP" => $nip]);
        if(count($pegawai) > 0) {
			$profesi = $pegawai[0]["PROFESI"];
			if($profesi == 3) $profesi = 6; 
            $ppa = $this->referensi->load([
                "JENIS" => 32,
                "REF_ID" => $profesi,
				"STATUS" => 1
            ]);
            if(count($ppa) > 0) return true;
        }
		return false;
	}
}