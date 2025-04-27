<?php
namespace Kemkes\V2\Rest\TerkonfirmasiTB;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as dbService;
use General\V1\Rest\Pasien\PasienService;
use Pendaftaran\V1\Rest\Kunjungan\KunjunganService;
use General\V1\Rest\Diagnosa\DiagnosaService;

class Service extends dbService{
    private $pasien;
    private $kunjungan;
    private $diagnosa;

    protected $references = [
        "Pasien" => true,
        "Kunjungan" =>  true,
        "Diagnosa" => true
    ];

    public function __construct($includeReferences = true, $references = []){
        $this->config["entityName"] = "\\Kemkes\\V2\\Rest\\TerkonfirmasiTB\\TerkonfirmasiTBEntity";
        $this->config["entityId"] = "ID";
        $this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("terkonfirmasi_tb","kemkes"));
        $this->entity = new TerkonfirmasiTBEntity();

        $this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
				
		if($includeReferences) {
			if($this->references['Pasien']) $this->pasien = new PasienService();
            if($this->references['Diagnosa']) $this->diagnosa = new DiagnosaService();
            if($this->references['Kunjungan']) $this->kunjungan = new KunjunganService(true, [
                'Ruangan' => true,
                'Referensi' => false,
                'Pendaftaran' => false,
                'RuangKamarTidur' => false,
                'PasienPulang' => false,
                'Pembatalan' => false,
                'Perujuk' => false,
                'Mutasi' => false,
                'RujukanKeluar' => false
            ]);
        }
    }

    public function load($params = array(), $columns = array('*'), $orders = array()) {
		$data = parent::load($params, $columns, $orders);
		
		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['Pasien']) {
					$pasien = $this->pasien->load(['NORM' => $entity['NORM']]);
					if(count($pasien) > 0) $entity['REFERENSI']['PASIEN'] = $pasien[0];
                }

                if($this->references['Diagnosa']) {
					$diagnosa = $this->diagnosa->load(['CODE' => $entity['DIAGNOSA']], ["CODE","STR"]);
					if(count($diagnosa) > 0) $entity['REFERENSI']['DIAGNOSA'] = $diagnosa[0];
                }

                if($this->references['Kunjungan']) {
					$kunjungan = $this->kunjungan->load(['NOMOR' => $entity['KUNJUNGAN']]);
					if(count($kunjungan) > 0) $entity['REFERENSI']['KUNJUNGAN'] = $kunjungan[0];
                }
            }
        }

        return $data;
    }
}