<?php
namespace Kemkes\IHS\V1\Rest\TindakanToLoinc;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use Kemkes\IHS\V1\Rest\TypeCodeReference\Service as typeCodeService;
use Kemkes\IHS\V1\Rest\Loinc\Service as loincService;

class Service extends DBService
{    
    
    private $typecode;
    private $loinc;

    public function __construct($includeReferences = true, $references = []) {
        $this->config["entityName"] = "Kemkes\\IHS\\V1\\Rest\\TindakanToLoinc\\TindakanToLoincEntity";
        $this->config["autoIncrement"] = false;
        $this->config["entityId"] = "TINDAKAN";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("tindakan_to_loinc", "kemkes-ihs"));
        $this->entity = new TindakanToLoincEntity();
        $this->typecode = new typeCodeService();
        $this->loinc = new loincService();
    }

    public function load($params = array(), $columns = array('*'), $orders = array()) {
		$data = parent::load($params, $columns, $orders);
		foreach($data as &$entity) {
            $loinc = $this->loinc->load(['id' => $entity['LOINC_TERMINOLOGI']]);
			if(count($loinc) > 0) $entity['REFERENSI']['LOINC_TERMINOLOGI'] = $loinc[0];

            $spe = $this->typecode->load(['type' => 52, 'ID' => $entity['SPESIMENT']]);
			if(count($spe) > 0) $entity['REFERENSI']['SPESIMENT'] = $spe[0];

            $kat = $this->typecode->load(['type' => 58, 'ID' => $entity['KATEGORI']]);
			if(count($kat) > 0) $entity['REFERENSI']['KATEGORI'] = $kat[0];
		}
				
		return $data;
	}

    protected function queryCallback(Select &$select, &$params, $columns, $orders) {
        if(!System::isNull($params, 'query')) {
            $params[] = new \Laminas\Db\Sql\Predicate\Expression("(Kategori_pemeriksaan LIKE ? OR nama_pemeriksaan LIKE ? OR code LIKE ?)", ["%".$params["query"]."%", "%".$params["query"]."%", "%".$params["query"]."%"]);
			unset($params['query']);
		}
    }
}