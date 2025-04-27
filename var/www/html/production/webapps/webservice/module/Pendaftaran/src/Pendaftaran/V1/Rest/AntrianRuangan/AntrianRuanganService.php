<?php
namespace Pendaftaran\V1\Rest\AntrianRuangan;

use DBService\DatabaseService;
use Laminas\Db\Sql\Select;
use DBService\generator\Generator;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Expression;
use Laminas\json\Json;
use DBService\System;
use DBService\Service;

use General\V1\Rest\Ruangan\RuanganService;
use Pendaftaran\V1\Rest\TujuanPasien\TujuanPasienService;

class AntrianRuanganService extends Service
{   
	protected $references = [
		'ruangan' => true,
		'tujuanPasien' => true
	];
	
    public function __construct($includeReferences = true, $references = []) {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("antrian_ruangan", "pendaftaran"));
		$this->entity = new AntrianRuanganEntity();
		
		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {
			if($this->references['ruangan']) $this->ruangan = new RuanganService();
			if($this->references['tujuanPasien']) $this->tujuanPasien = new TujuanPasienService(true, ['AntrianRuangan' => false]);
		}
    }
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		
		if($this->includeReferences) {
			foreach($data as &$entity) {
				
				if($this->references['ruangan']) {
					$ruangan = $this->ruangan->load(['ID' => $entity['RUANGAN']]);
					if(count($ruangan) > 0) $entity['REFERENSI']['RUANGAN'] = $ruangan[0];
				}
				
				if($this->references['tujuanPasien']) {
					$tujuanPasien = $this->tujuanPasien->load(['NOPEN' => $entity['REF']]);
					if(count($tujuanPasien) > 0) $entity['REFERENSI']['TUJUAN_PASIEN'] = $tujuanPasien[0];
				}
				
			}
		}
		
		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'STATUS')) {
			$params['antrian_ruangan.STATUS'] = $params['STATUS'];
			unset($params['STATUS']);
		}

		if(!System::isNull($params, 'RUANGAN')) {
			$params['antrian_ruangan.RUANGAN'] = $params['RUANGAN'];
			if(isset($params['STATUS_KUNJUNGAN'])) $params['k.RUANGAN'] = $params['RUANGAN'];
			unset($params['RUANGAN']);
		}

		if(!System::isNull($params, 'STATUS_KUNJUNGAN')) {
			$params['k.STATUS'] = $params['STATUS_KUNJUNGAN'];
			unset($params['STATUS_KUNJUNGAN']);

			$select->join(
				['k'=>new TableIdentifier('kunjungan', 'pendaftaran')], 
				new \Laminas\Db\Sql\Predicate\Expression("k.NOPEN = antrian_ruangan.REF AND k.MASUK BETWEEN CONCAT(DATE(NOW()), ' 00:00:00') AND NOW()"),
				[]
			);
		}
	}
}