<?php
namespace Kemkes\db\sitb\pasien_tb;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

use General\V1\Rest\Referensi\ReferensiService;
use General\V1\Rest\Pasien\PasienService;
use General\V1\Rest\Wilayah\WilayahService;
use General\V1\Rest\Diagnosa\DiagnosaService;
use General\V1\Rest\Ruangan\RuanganService;

class Service extends DBService
{
    private $referensi;
    private $pasien;
    private $wilayah;
    private $icd;
    private $asalPoli;
    
    protected $references = [
        "Referensi" => true,
        "Pasien" => true,
        "Wilayah" => true,
        "ICD" => true,
        "AsalPoli" => true
    ];
    
    public function __construct($includeReferences = true, $references = []) {
        $this->config["entityName"] = "Kemkes\db\sitb\pasien_tb\\Entity";
        $this->config["entityId"] = "id";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("pasien_tb", "kemkes"));
        $this->entity = new Entity();
        
        $this->setReferences($references);
        
        $this->includeReferences = $includeReferences;
        
        if($includeReferences) {
            if($this->references['Referensi']) $this->referensi = new ReferensiService();
            if($this->references['Pasien']) $this->pasien = new PasienService();
            if($this->references['Wilayah']) $this->wilayah = new WilayahService();
            if($this->references['ICD']) $this->icd = new DiagnosaService();
            if($this->references['AsalPoli']) $this->asalPoli = new RuanganService();
        }
    }
    
    public function load($params = [], $columns = ['*'], $orders = []) {
        $data = parent::load($params, $columns, $orders);
        
        if($this->includeReferences) {
            foreach($data as &$entity) {
                if($this->references["Referensi"]) {
                    $referensi = $this->referensi->load(["JENIS" => 2, "ID" => $entity["jenis_kelamin"]]);
                    if(count($referensi) > 0) $entity['REFERENSI']['jenis_kelamin'] = $referensi[0];
                    
                    $referensi = $this->referensi->load(["JENIS" => 92, "ID" => $entity["nama_rujukan"]]);
                    if(count($referensi) > 0) $entity['REFERENSI']['nama_rujukan'] = $referensi[0];
                    
                    $referensi = $this->referensi->load(["JENIS" => 93, "ID" => $entity["tipe_diagnosis"]]);
                    if(count($referensi) > 0) $entity['REFERENSI']['tipe_diagnosis'] = $referensi[0];
                    
                    $referensi = $this->referensi->load(["JENIS" => 94, "ID" => $entity["klasifikasi_lokasi_anatomi"]]);
                    if(count($referensi) > 0) $entity['REFERENSI']['klasifikasi_lokasi_anatomi'] = $referensi[0];
                    
                    $referensi = $this->referensi->load(["JENIS" => 95, "ID" => $entity["klasifikasi_riwayat_pengobatan"]]);
                    if(count($referensi) > 0) $entity['REFERENSI']['klasifikasi_riwayat_pengobatan'] = $referensi[0];
                    
                    $referensi = $this->referensi->load(["JENIS" => 96, "ID" => $entity["klasifikasi_status_hiv"]]);
                    if(count($referensi) > 0) $entity['REFERENSI']['klasifikasi_status_hiv'] = $referensi[0];
                    
                    $referensi = $this->referensi->load(["JENIS" => 97, "ID" => $entity["total_skoring_anak"]]);
                    if(count($referensi) > 0) $entity['REFERENSI']['total_skoring_anak'] = $referensi[0];
                    
                    $referensi = $this->referensi->load(["JENIS" => 98, "ID" => $entity["konfirmasiSkoring5"]]);
                    if(count($referensi) > 0) $entity['REFERENSI']['konfirmasiSkoring5'] = $referensi[0];
                    
                    $referensi = $this->referensi->load(["JENIS" => 99, "ID" => $entity["konfirmasiSkoring6"]]);
                    if(count($referensi) > 0) $entity['REFERENSI']['konfirmasiSkoring6'] = $referensi[0];
                    
                    //$referensi = $this->referensi->load(["JENIS" => 100, "ID" => $entity["paduan_oat"]]);
                    //if(count($referensi) > 0) $entity['REFERENSI']['paduan_oat'] = $referensi[0];
                    
                    $referensi = $this->referensi->load(["JENIS" => 101, "ID" => $entity["sumber_obat"]]);
                    if(count($referensi) > 0) $entity['REFERENSI']['sumber_obat'] = $referensi[0];
                    
                    $referensi = $this->referensi->load(["JENIS" => 103, "ID" => $entity["sebelum_pengobatan_hasil_mikroskopis"]]);
                    if(count($referensi) > 0) $entity['REFERENSI']['sebelum_pengobatan_hasil_mikroskopis'] = $referensi[0];
                    
                    $referensi = $this->referensi->load(["JENIS" => 104, "ID" => $entity["sebelum_pengobatan_hasil_tes_cepat"]]);
                    if(count($referensi) > 0) $entity['REFERENSI']['sebelum_pengobatan_hasil_tes_cepat'] = $referensi[0];
                    
                    $referensi = $this->referensi->load(["JENIS" => 105, "ID" => $entity["sebelum_pengobatan_hasil_biakan"]]);
                    if(count($referensi) > 0) $entity['REFERENSI']['sebelum_pengobatan_hasil_biakan'] = $referensi[0];
                    
                    $referensi = $this->referensi->load(["JENIS" => 106, "ID" => $entity["hasil_mikroskopis_bulan_2"]]);
                    if(count($referensi) > 0) $entity['REFERENSI']['hasil_mikroskopis_bulan_2'] = $referensi[0];
                    
                    $referensi = $this->referensi->load(["JENIS" => 107, "ID" => $entity["hasil_mikroskopis_bulan_3"]]);
                    if(count($referensi) > 0) $entity['REFERENSI']['hasil_mikroskopis_bulan_3'] = $referensi[0];
                    
                    $referensi = $this->referensi->load(["JENIS" => 108, "ID" => $entity["hasil_mikroskopis_bulan_5"]]);
                    if(count($referensi) > 0) $entity['REFERENSI']['hasil_mikroskopis_bulan_5'] = $referensi[0];
                    
                    $referensi = $this->referensi->load(["JENIS" => 109, "ID" => $entity["akhir_pengobatan_hasil_mikroskopis"]]);
                    if(count($referensi) > 0) $entity['REFERENSI']['akhir_pengobatan_hasil_mikroskopis'] = $referensi[0];
                    
                    $referensi = $this->referensi->load(["JENIS" => 110, "ID" => $entity["hasil_akhir_pengobatan"]]);
                    if(count($referensi) > 0) $entity['REFERENSI']['hasil_akhir_pengobatan'] = $referensi[0];
                    
                    $referensi = $this->referensi->load(["JENIS" => 111, "ID" => $entity["hasil_tes_hiv"]]);
                    if(count($referensi) > 0) $entity['REFERENSI']['hasil_tes_hiv'] = $referensi[0];
                    
                    $referensi = $this->referensi->load(["JENIS" => 112, "ID" => $entity["ppk"]]);
                    if(count($referensi) > 0) $entity['REFERENSI']['ppk'] = $referensi[0];
                    
                    $referensi = $this->referensi->load(["JENIS" => 113, "ID" => $entity["art"]]);
                    if(count($referensi) > 0) $entity['REFERENSI']['art'] = $referensi[0];
                    
                    $referensi = $this->referensi->load(["JENIS" => 114, "ID" => $entity["tb_dm"]]);
                    if(count($referensi) > 0) $entity['REFERENSI']['tb_dm'] = $referensi[0];
                    
                    $referensi = $this->referensi->load(["JENIS" => 115, "ID" => $entity["terapi_dm"]]);
                    if(count($referensi) > 0) $entity['REFERENSI']['terapi_dm'] = $referensi[0];
                    
                    $referensi = $this->referensi->load(["JENIS" => 117, "ID" => $entity["status_pengobatan"]]);
                    if(count($referensi) > 0) $entity['REFERENSI']['status_pengobatan'] = $referensi[0];
                    
                    $referensi = $this->referensi->load(["JENIS" => 102, "ID" => $entity["foto_toraks"]]);
                    if(count($referensi) > 0) $entity['REFERENSI']['foto_toraks'] = $referensi[0];
                    
                    $referensi = $this->referensi->load(["JENIS" => 118, "ID" => $entity["toraks_tdk_dilakukan"]]);
                    if(count($referensi) > 0) $entity['REFERENSI']['toraks_tdk_dilakukan'] = $referensi[0];
                    
                    $referensi = $this->referensi->load(["JENIS" => 116, "ID" => $entity["pindah_ro"]]);
                    if(count($referensi) > 0) $entity['REFERENSI']['pindah_ro'] = $referensi[0];
                }

                if($this->references["Pasien"]) {
                    $pasien = $this->pasien->load(["NORM" => $entity["nourut_pasien"]]);
                    if(count($pasien) > 0) $entity['REFERENSI']['pasien'] = $pasien[0];
                }

                if($this->references["Wilayah"]) {
                    $wilayah = $this->wilayah->load(["ID" => $entity["id_propinsi_pasien"], "JENIS" => 1]);
                    if(count($wilayah) > 0) $entity['REFERENSI']['propinsi_pasien'] = $wilayah[0];

                    $wilayah = $this->wilayah->load(["ID" => $entity["kd_kabupaten_pasien"], "JENIS" => 2]);
                    if(count($wilayah) > 0) $entity['REFERENSI']['kabupaten_pasien'] = $wilayah[0];

                    $wilayah = $this->wilayah->load(["ID" => $entity["id_kecamatan_pasien"], "JENIS" => 3]);
                    if(count($wilayah) > 0) $entity['REFERENSI']['kecamatan_pasien'] = $wilayah[0];
                }

                if($this->references["ICD"]) {
                    $icd = $this->icd->load(["CODE" => $entity["kode_icd_x"]]);
                    if(count($icd) > 0) $entity['REFERENSI']['kode_icd_x'] = $icd[0];
                }
                if($this->references["AsalPoli"]) {
                    $asalPoli = $this->asalPoli->load(["ID" => $entity["asal_poli"]]);
                    if(count($asalPoli) > 0) $entity['REFERENSI']['asal_poli'] = $asalPoli[0];
                }
            }
        }
        
        return $data;
    }
}