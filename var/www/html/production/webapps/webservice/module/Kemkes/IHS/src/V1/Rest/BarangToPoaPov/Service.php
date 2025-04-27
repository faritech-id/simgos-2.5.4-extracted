<?php
namespace Kemkes\IHS\V1\Rest\BarangToPoaPov;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;

use Kemkes\IHS\V1\Rest\POV\Service as povService;
use Kemkes\IHS\V1\Rest\POA\Service as poaService;
use Kemkes\IHS\V1\Rest\TypeCodeReference\Service as typeCodeService;
use Kemkes\IHS\V1\Rest\BarangToBza\Service as barangToBzaService;

class Service extends DBService
{    
    private $pov;
    private $poa;
    private $typecode;
    private $barangtobza;

    public function __construct($includeReferences = true, $references = []) {
        $this->config["entityName"] = "Kemkes\\IHS\\V1\\Rest\\BarangToPoaPov\\BarangToPoaPovEntity";
        $this->config["autoIncrement"] = false;
        $this->config["entityId"] = "BARANG";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("barang_to_poa_pov", "kemkes-ihs"));
        $this->entity = new BarangToPoaPovEntity();

        $this->pov = new povService();
        $this->poa = new poaService();
        $this->typecode = new typeCodeService();
        $this->barangtobza = new barangToBzaService();
    }

    public function load($params = array(), $columns = array('*'), $orders = array()) {
		$data = parent::load($params, $columns, $orders);
		foreach($data as &$entity) {
            $pov = $this->pov->load(['id' => $entity['KODE_POV']]);
			if(count($pov) > 0) $entity['REFERENSI']['POV'] = $pov[0];
            
            $poa = $this->poa->load(['id' => $entity['KODE_POA']]);
			if(count($poa) > 0) $entity['REFERENSI']['POA'] = $poa[0];

            $st = $this->typecode->load(['type' => 29, 'ID' => $entity['RUTE_OBAT']]);
			if(count($st) > 0) $entity['REFERENSI']['RUTE_OBAT'] = $st[0];
		}
				
		return $data;
	}

    protected function onAfterSaveCallback($id, $data) {
        if(isset($data["REFERENSI"])){
            $referensi = $data["REFERENSI"];
            if(isset($referensi["POA"])) $this->savePoa($referensi["POA"]);
            if(isset($referensi["POV"])) $this->savePov($referensi["POV"]);
        }

        if(isset($data["BARANG_TO_BZA"])) $this->saveBarangToBza($id, $data["BARANG_TO_BZA"]);
    }

    private function savePoa($data){
        $cek = $this->poa->load(['id' => $data["id"]]);
        if(count($cek) == 0) {
            if(empty($data["url"])) $data["url"] = "https://dto.kemkes.go.id/kfacode/".$data["id"];
            $this->poa->simpanData($data, count($cek) == 0);
        }
    }

    private function savePov($data){
        $cek = $this->pov->load(['id' => $data["id"]]);
        if(count($cek) == 0) {
            if(empty($data["url"])) $data["url"] = "https://dto.kemkes.go.id/kfacode/".$data["id"];
            $this->pov->simpanData($data, count($cek) == 0);
        }
    }

    private function saveBarangToBza($id, $data){
        foreach($data as $dtl) {
            $cek = $this->barangtobza->load([
                'BARANG' => $id,
                'KODE_BZA' => $dtl["KODE_BZA"]
            ]);
            $dtl["BARANG"] = $id;
            if(count($cek) > 0) $dtl["ID"] = $cek[0]["ID"];
            
            $this->barangtobza->simpanData($dtl, count($cek) == 0);
        }
    }
}