<?php
namespace General\V1\Rest\Diagnosa;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;

class DiagnosaService extends Service
{
    public function __construct() {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("mrconso", "master"));
		$this->entity = new DiagnosaEntity();
    }
		
	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		
		if(!System::isNull($params, 'ICD9')) {
			$select->where('(SAB = "ICD9CM_2005" OR SAB = "ICD9CM_2020")');
			unset($params['ICD9']);
		} elseif(!System::isNull($params, 'ICD')) {
			unset($params['ICD']);
		} else {
			$select->where('(SAB = "ICD10_1998" OR SAB = "ICD10_2020")');
		}
		$select->where("TTY IN ('PX', 'PT')");
		
		if(isset($params['CODE'])) {
			if(!System::isNull($params, 'CODE')) {
				$select->where->like('CODE', $params['CODE']);
				unset($params['CODE']);
			}
		}

		if(isset($params['STR'])) {
			if(!System::isNull($params, 'STR')) {
				$select->where->like('STR', '%'.$params['STR'].'%');
				unset($params['STR']);
			}
		}
		if(isset($params['QUERY'])) {
			if(!System::isNull($params, 'QUERY')) {
				$params[] = new \Laminas\Db\Sql\Predicate\Expression("(STR LIKE ? OR CODE LIKE ?)", ["%".$params["QUERY"]."%", $params["QUERY"]."%"]);
				unset($params['QUERY']);
			}
		}
	}
}
