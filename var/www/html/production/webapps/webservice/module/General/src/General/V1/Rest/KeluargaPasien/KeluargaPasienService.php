<?php
namespace General\V1\Rest\KeluargaPasien;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;
use DBService\generator\Generator;
use General\V1\Rest\KontakKeluargaPasien\KontakKeluargaPasienService;
use General\V1\Rest\KartuIdentitasKeluarga\Service as KartuIdentitasKeluargaService;

class KeluargaPasienService extends Service
{
    private $kontakKeluargaPasien;
	private $kartuIdentitasKeluarga;
	
    public function __construct() {
		$this->config["entityName"] = "General\\V1\\Rest\\KeluargaPasien\\KeluargaPasienEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("keluarga_pasien", "master"));
		$this->entity = new KeluargaPasienEntity();
		$this->kontakKeluargaPasien = new KontakKeluargaPasienService();
		$this->kartuIdentitasKeluarga = new KartuIdentitasKeluargaService();
    }
    
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		foreach($data as &$entity) {
			$kontaks = $this->kontakKeluargaPasien->load(['NORM' => $entity['NORM'], 'SHDK' => $entity['SHDK']]);
			if(count($kontaks) > 0) $entity['KONTAK'] = $kontaks;

			$kiks = $this->kartuIdentitasKeluarga->load(['KELUARGA_PASIEN_ID'=>$entity['ID']]);
			if(count($kiks) > 0) $entity['KARTU_IDENTITAS'] = $kiks;	
		}
		
		return $data;
	}

	protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
		$params = [
			"NORM" => $data["NORM"], 
			"JENIS_KELAMIN" => $data["JENIS_KELAMIN"], 
			"SHDK" => $data["SHDK"]
		];

		$nomor = $this->entity->get("NOMOR");
		$finds = $this->load($params);
		if(count($finds) == 0) {
			$nomor = Generator::generateIdKeluargaPasien(
				$data["SHDK"], $data["NORM"], $data["JENIS_KELAMIN"]
			);
			$this->entity->set('NOMOR', $nomor);
		}
	}

	protected function onAfterSaveCallback($id, $data) {
		$this->simpanKontakKeluarga($data);
		$this->simpanKartuIdentitasKeluarga($data, $id);
	}
	
	private function simpanKontakKeluarga($data) {
		if(isset($data['KONTAK'])) {
			foreach($data['KONTAK'] as $kon) {				
				$kon['SHDK'] = $data["SHDK"];
				$kon['NORM'] = $data["NORM"];
				
				$this->kontakKeluargaPasien->simpanData($kon); 
			}
		}
	}

	private function simpanKartuIdentitasKeluarga($data, $id) {
		if(isset($data['KARTU_IDENTITAS'])) {
			foreach($data['KARTU_IDENTITAS'] as $val) {
				$val['KELUARGA_PASIEN_ID'] = $id;
				$created = empty($val['ID']) ? true : !is_numeric($val['ID']);
				$this->kartuIdentitasKeluarga->simpanData($val, $created); 
			}
		}
	}

	public function getKIPKeluargaService() {
		return $this->kartuIdentitasKeluarga;
	}
}
