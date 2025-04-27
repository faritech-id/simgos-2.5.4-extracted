<?php
namespace Kemkes\IHS\V1\Rest\BarangToBza;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use Kemkes\IHS\V1\Rest\BZA\Service as bzaService;
use Kemkes\IHS\V1\Rest\TypeCodeReference\Service as typeCodeService;

class Service extends DBService
{    
    private $bza;
    private $typecode;
    public function __construct($includeReferences = true, $references = []) {
        $this->config["entityName"] = "Kemkes\\IHS\\V1\\Rest\\BarangToBza\\BarangToBzaEntity";
        $this->config["autoIncrement"] = true;
        $this->config["entityId"] = "ID";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("barang_to_bza", "kemkes-ihs"));
        $this->entity = new BarangToBzaEntity();
        $this->bza = new bzaService();
        $this->typecode = new typeCodeService();
    }

    public function load($params = array(), $columns = array('*'), $orders = array()) {
		$data = parent::load($params, $columns, $orders);
		foreach($data as &$entity) {
            $bza = $this->bza->load(['ID' => $entity['KODE_BZA']]);
			if(count($bza) > 0) $entity['REFERENSI']['BZA'] = $bza[0];

            $stfa = $this->typecode->load(['type' => 19, 'ID' => $entity['SATUAN_DOSIS_KFA']]);
			if(count($stfa) > 0) $entity['REFERENSI']['SATUAN_DOSIS_KFA'] = $stfa[0];

            $st = $this->typecode->load(['type' => 19, 'ID' => $entity['SATUAN']]);
			if(count($st) > 0) $entity['REFERENSI']['SATUAN'] = $st[0];
		}
				
		return $data;
	}

    protected function onAfterSaveCallback($id, $data) {
        if(isset($data["REFERENSI"])){
            $referensi = $data["REFERENSI"];
            if(isset($referensi["BZA"])) $this->saveBza($referensi["BZA"]);
        }
    }

    private function saveBza($data){
        $cek = $this->bza->load(['id' => $data["id"]]);
        if(count($cek) == 0) {
            if(empty($data["url"])) $data["url"] = "https://dto.kemkes.go.id/kfacode/".$data["id"];
            $this->bza->simpanData($data, count($cek) == 0);
        }
    }
}