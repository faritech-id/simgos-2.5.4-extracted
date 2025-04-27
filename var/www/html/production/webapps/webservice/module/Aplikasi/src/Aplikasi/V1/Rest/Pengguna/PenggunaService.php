<?php
namespace Aplikasi\V1\Rest\Pengguna;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;
use Aplikasi\Password;

use General\V1\Rest\Referensi\ReferensiService;
use General\V1\Rest\Pegawai\PegawaiService;

class PenggunaService extends Service
{
	private $referensi;
	private $pegawai;
	
    public function __construct() {
		$this->config["entityName"] = "Aplikasi\\V1\\Rest\\Pengguna\\PenggunaEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("pengguna", "aplikasi"));
		$this->entity = new PenggunaEntity();
		
		$this->referensi = new ReferensiService();
		$this->pegawai = new PegawaiService();
    }
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		
		foreach($data as &$entity) {
			if(isset($entity['JENIS'])) {
				$referensi = $this->referensi->load(['JENIS' => 69,'ID' => $entity['JENIS']]);
				if(count($referensi) > 0) $entity['REFERENSI']['JENIS_PENGGUNA'] = $referensi[0];
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
	}

	protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
		if(isset($data["PASSWORD"])) {
    		$pass = Password::encrypt($data['PASSWORD']);
    		$entity->set('PASSWORD', $pass);
		}
		if(!$isCreated) $entity->set('TERAKHIR_UBAH_PASSWOD', new \Laminas\Db\Sql\Expression('NOW()'));
	}

	public function getPegawaiService() {
		return $this->pegawai;
	}

	public function getPegawai($penggunaId) {
		$pengguna = $this->load([
			"ID" => $penggunaId
		]);

		if(count($pengguna) > 0) {
			$pegawai = $this->pegawai->load([
				"NIP" => $pengguna[0]["NIP"]
			]);
			if(count($pegawai) > 0) return $pegawai[0];
		}

		return false;
	}

	public function getPegawaiByNIP($nip) {
		$pegawai = $this->pegawai->load([
			"NIP" => $nip
		]);
		if(count($pegawai) > 0) return $pegawai[0];

		return false;
	}
}
