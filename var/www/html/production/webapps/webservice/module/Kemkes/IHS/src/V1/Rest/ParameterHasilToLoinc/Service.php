<?php
namespace Kemkes\IHS\V1\Rest\ParameterHasilToLoinc;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;
use Kemkes\IHS\V1\Rest\Loinc\Service as loincService;
use General\V1\Rest\ParameterTindakanLab\ParameterTindakanLabService;

class Service extends DBService
{    
    private $loinc;
    private $parameter;

    public function __construct($includeReferences = true, $references = []) {
        $this->config["entityName"] = "Kemkes\\IHS\\V1\\Rest\\ParameterHasilToLoinc\\ParameterHasilToLoincEntity";
        $this->config["autoIncrement"] = false;
        $this->config["entityId"] = "PARAMETER_HASIL";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("parameter_hasil_to_loinc", "kemkes-ihs"));
        $this->entity = new ParameterHasilToLoincEntity();
        $this->loinc = new loincService();
        $this->parameter = new ParameterTindakanLabService();
    }

    public function load($params = array(), $columns = array('*'), $orders = array()) {
		$data = parent::load($params, $columns, $orders);
		foreach($data as &$entity) {

            $loinc = $this->loinc->load(['id' => $entity['LOINC_TERMINOLOGI']]);
			if(count($loinc) > 0) $entity['REFERENSI']['LOINC_TERMINOLOGI'] = $loinc[0];

            $parameter = $this->parameter->load(['ID' => $entity['PARAMETER_HASIL']]);
			if(count($parameter) > 0) $entity['REFERENSI']['PARAMETER_HASIL'] = $parameter[0];
		}
				
		return $data;
	}

    protected function queryCallback(Select &$select, &$params, $columns, $orders) {
        if(!System::isNull($params, 'TINDAKAN')) {
            $select->join(['ptl'=>new TableIdentifier('parameter_tindakan_lab', 'master')], 'ptl.ID = parameter_hasil_to_loinc.PARAMETER_HASIL', []);
            $params["ptl.TINDAKAN"] = $params["TINDAKAN"];
			unset($params['TINDAKAN']);
		}
    }
}