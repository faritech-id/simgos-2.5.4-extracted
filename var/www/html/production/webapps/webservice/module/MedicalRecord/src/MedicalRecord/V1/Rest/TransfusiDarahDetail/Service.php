<?php
namespace MedicalRecord\V1\Rest\TransfusiDarahDetail;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;

class Service  extends DBService
{
    public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\TransfusiDarahDetail\\TransfusiDarahDetailEntity";
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("pemeriksaan_transfusi_darah_detail", "medicalrecord"));
		$this->entity = new TransfusiDarahDetailEntity();
    }
	
	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'STATUS')) {
			$params['pemeriksaan_transfusi_darah_detail.STATUS'] = $params['STATUS'];
			unset($params['STATUS']);
		}

		if(!System::isNull($params, 'ID')) {
			$params['pemeriksaan_transfusi_darah_detail.ID'] = $params['ID'];
			unset($params['ID']);
		}

		if(!System::isNull($params, 'NOMOR_KANTONG')) {
			$select->where->like('NOMOR_KANTONG', '%'.$params['NOMOR_KANTONG'].'%');
			unset($params['NOMOR_KANTONG']);
		}
		
		$select->join(
			['p' => new TableIdentifier("pemeriksaan_transfusi_darah", "medicalrecord")],
			'p.ID = pemeriksaan_transfusi_darah_detail.TRANSFUSI_DARAH',
			[],
			Select::JOIN_LEFT
		);

		if(!System::isNull($params, 'KUNJUNGAN')) {
			$params['p.KUNJUNGAN'] = $params['KUNJUNGAN'];
			unset($params['KUNJUNGAN']);
		}
	}
} 