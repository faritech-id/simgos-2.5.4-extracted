<?php
namespace LISService\V1\Rest\PrefixParameter;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;

use LISService\V1\Rest\Parameter\Service as ParameterService;

class Service extends DBService {
	private $parameter;

	public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "LISService\\V1\\Rest\\PrefixParameter\\PrefixParameterEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("prefix_parameter_lis", "lis"));
		$this->entity = new PrefixParameterEntity();

		$this->parameter = new ParameterService();
	}

	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);

		foreach($data as &$entity) {
			$parameter = $this->parameter->load(['VENDOR_ID' => $entity['VENDOR_ID'], "KODE" => $entity["LIS_KODE_TEST"]]);
			if(count($parameter) > 0) $entity['REFERENSI']['PARAMETER'] = $parameter[0];
		}
		
		return $data;
	}
}