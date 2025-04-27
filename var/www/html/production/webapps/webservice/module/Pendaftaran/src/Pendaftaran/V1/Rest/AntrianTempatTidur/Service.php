<?php
namespace Pendaftaran\V1\Rest\AntrianTempatTidur;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as dbService;
use Pendaftaran\V1\Rest\Pemohon\Service as PemohonService;
use General\V1\Rest\Ruangan\RuanganService;
use General\V1\Rest\Pasien\PasienService;
use General\V1\Rest\Referensi\ReferensiService;
use General\V1\Rest\Dokter\DokterService;

class Service extends dbService{
    private $PemohonService;
    private $Ruangan;
    private $Pasien;
    private $Referensi;
    private $Dokter;

    protected $references = array(
		'Pasien' => true,		
		'Ruangan' => true,
		'Kelas' => true,
        'Dokter' => true,
        'Pemohon' => true
	);

    public function __construct($includeReferences = true, $references = []){
        $this->config["entityName"] = "\\Pendaftaran\\V1\\Rest\\AntrianTempatTidur\\AntrianTempatTidurEntity";
        $this->config["entityId"] = "ID";
        $this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("antrian_tempat_tidur","pendaftaran"));
        $this->entity = new AntrianTempatTidurEntity();
        
        $this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		$this->PemohonService = new PemohonService(); 

		if($includeReferences) {
            if($this->references['Pasien']) $this->Pasien = new PasienService();
            if($this->references['Ruangan']) $this->Ruangan = new RuanganService();
            if($this->references['Kelas']) $this->Referensi = new ReferensiService();
            if($this->references['Dokter']) $this->Dokter = new DokterService(false, []);
        }
    }

    protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
        if(isset($data["PEMOHON"])){
            $pemohon = $data["PEMOHON"];
            /* status untuk update atau create data pemohon */
            $create = is_numeric($pemohon['ID']) ? false : true;
            $ID = $this->PemohonService->simpanData($data["PEMOHON"], $create, false);
            $entity["PEMOHON_ID"] = $ID;
        }
    }

    public function load($params = array(), $columns = array('*'), $orders = array()) {
		$data = parent::load($params, $columns, $orders);
		foreach($data as &$entity) {
            if($this->references['Ruangan']){
                $Ruangan = $this->Ruangan->load(array('ID' => $entity['RENCANA_RUANGAN']));
                if(count($Ruangan) > 0) $entity['REFERENSI']['RENCANA_RUANGAN'] = $Ruangan[0];

                $Ruangan = $this->Ruangan->load(array('ID' => $entity['RENCANA_RUANGAN_ALTERNATIF']));
                if(count($Ruangan) > 0) $entity['REFERENSI']['RENCANA_RUANGAN_ALTERNATIF'] = $Ruangan[0];
            }

            if($this->references['Pasien']){
                $pasien = $this->Pasien->load(array('NORM' => $entity['NORM']));
                if(count($pasien) > 0) $entity['REFERENSI']['PASIEN'] = $pasien[0];
            }

            if($this->references['Kelas']){
                $kelas = $this->Referensi->load(array('ID' => $entity['RENCANA_KELAS'], 'JENIS' => 19));
                if(count($kelas) > 0) $entity['REFERENSI']['RENCANA_KELAS'] = $kelas[0];
            }

            if($this->references['Dokter']){
                $dokter = $this->Dokter->load(array('ID' => $entity['DPJP']));
                if(count($dokter) > 0) $entity['REFERENSI']['DPJP'] = $dokter[0];
            }

            if($this->references['Pemohon']){
                $pemohon = $this->PemohonService->load(array('ID' => $entity['PEMOHON_ID']));
                if(count($pemohon) > 0) $entity['REFERENSI']['PEMOHON'] = $pemohon[0];
            }
		}
        	
		return $data;
	}
}