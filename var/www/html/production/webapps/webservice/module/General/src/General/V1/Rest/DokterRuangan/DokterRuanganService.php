<?php
namespace General\V1\Rest\DokterRuangan;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use Zend\json\Json;
use DBService\System;
use DBService\Service;

use General\V1\Rest\Ruangan\RuanganService;
use General\V1\Rest\Dokter\DokterService;

class DokterRuanganService extends Service
{
	private $ruangan;
	private $dokter;	
	
	protected $references = [
		'Ruangan' => true,
		'Dokter' => true
	];
	
    public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "General\\V1\\Rest\\DokterRuangan\\DokterRuanganEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("dokter_ruangan", "master"));
		$this->entity = new DokterRuanganEntity();
		
		$this->limit = 1000;
		
		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		if($includeReferences) {			
			if($this->references['Ruangan']) $this->ruangan = new RuanganService();
			if($this->references['Dokter']) $this->dokter = new DokterService();
		}
    }
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		
		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['Ruangan']) {
					$ruangan = $this->ruangan->load(['ID' => $entity['RUANGAN']]);
					if(count($ruangan) > 0) $entity['REFERENSI']['RUANGAN'] = $ruangan[0];
				}
				if($this->references['Dokter']) {
					$dokter = $this->dokter->load(['ID' => $entity['DOKTER']]);
					if(count($dokter) > 0) $entity['REFERENSI']['DOKTER'] = $dokter[0];
				}
			}
		}
		
		return $data;
	}

	protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
		$this->entity->set('TANGGAL', new \Laminas\Db\Sql\Expression('NOW()'));
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'ID')) {
			$params['dokter_ruangan.ID'] = $params['ID'];
			unset($params['ID']);
		}
		if(!System::isNull($params, 'STATUS')) {
			$params['dokter_ruangan.STATUS'] = $params['STATUS'];
			unset($params['STATUS']);
		}
		if(!System::isNull($params, 'NIP')) { 
			$select->join(
				['d' => new TableIdentifier("dokter", "master")], 
				"dokter_ruangan.DOKTER = d.ID", 
				[]
			);
			$params['d.NIP'] = $params['NIP'];
			unset($params['NIP']);
		}

		if(isset($params['QUERY'])) {
			if(!System::isNull($params, 'QUERY')) {
				/** pengecekan param nip untuk join ke table dokter dan pegawai */
				if(System::isNull($params, 'NIP')) { 
					$select->join(
						['d' => new TableIdentifier("dokter", "master")], 
						"dokter_ruangan.DOKTER = d.ID", 
						[]
					);
				}

				$select->join(
					['p' => new TableIdentifier("pegawai", "master")], 
					"d.NIP = p.NIP", 
					["NIP", "NAMA", "GELAR_DEPAN", "GELAR_BELAKANG"]
				);
				$params[] = new \Laminas\Db\Sql\Predicate\Expression("(p.NAMA LIKE ? OR p.NIP LIKE ?)", ["%".$params["QUERY"]."%", $params["QUERY"]."%"]);
				unset($params['QUERY']);
			}
		}
	}
	
    public function tambahSemuaDokter($ruangan) {
        $adapter = $this->table->getAdapter();
        $stmt = $adapter->query('CALL master.tambahSemuaDokterKeRuangan(?)');
		$stmt->execute([$ruangan]);
        
        return [
			'success' => true
		];
    }
}