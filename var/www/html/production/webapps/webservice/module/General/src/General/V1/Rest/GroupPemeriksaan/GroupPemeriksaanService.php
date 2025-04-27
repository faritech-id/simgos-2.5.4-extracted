<?php
namespace General\V1\Rest\GroupPemeriksaan;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;
use General\V1\Rest\Referensi\ReferensiService;

class GroupPemeriksaanService extends Service
{
	private $referensi;
	protected $references = [
		'Referensi' => true		
	];

	public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "General\\V1\Rest\GroupPemeriksaan\GroupPemeriksaanEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("group_pemeriksaan", "master"));
		$this->entity = new GroupPemeriksaanEntity();
		
		$this->referensi = new ReferensiService();
	}

	
	public function loadTree($params = []) {
		$params['LEVEL'] = isset($params["LEVEL"]) ? $params["LEVEL"] : 1;
		$data =  $this->queryRekursif($params);
		return [
			'total' => count($data),
			'data'=> $data
		];
    }
	
	protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
		if($isCreated) {
			if(isset($data['PARENT'])) {
				$data['PARENT']['LEVEL']++;
				$data['PARENT']['start'] = 0;
				$data['PARENT']['limit'] = 1;
				$cari = $this->query(['*'], $data['PARENT'], false, ["KODE DESC"]);
				
				if(count($cari) > 0){
					$entity->set('KODE', $data['PARENT']['KODE'].str_pad((intval(substr($cari[0]['KODE'],-2))+1), 2, 0, STR_PAD_LEFT));
				} else {
					$entity->set('KODE', $data['PARENT']['KODE'].'01');
				}
			} else {
			    $data['PARENT']['LEVEL'] = 1;
			    $data['PARENT']['start'] = 0;
			    $data['PARENT']['limit'] = 1;
				$data['PARENT']['JENIS'] = $data["JENIS"];
			    $cari = $this->query(['*'], $data['PARENT'], false, ["KODE DESC"]);
			    
			    if(count($cari) > 0){
			        $entity->set('KODE', $cari[0]['KODE']+1);
			    } else {
			        $entity->set('KODE', '10');
			    }
			}
		}
	}
	
	
	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(isset($params['KODE'])) {
			$select->where->like('KODE', $params['KODE'].'%');
			unset($params['KODE']);
		}
		if(isset($params['LEVEL'])) {
			$select->where(['LEVEL' => $params['LEVEL']]);
			unset($params['LEVEL']);
		}
		if(isset($params['DESKRIPSI'])) {
			$select->where->like('DESKRIPSI', $params['DESKRIPSI'].'%');
			unset($params['DESKRIPSI']);
		}
	}

	private function queryRekursif($params = []){
		$data = $this->query(['*'], $params);
		$a = 0;
		foreach($data as $dt){
			$params['KODE'] = $dt['KODE'];
			$params['LEVEL'] = $dt['LEVEL']+1;
			$params['JENIS'] = $dt['JENIS'];
			$childs = $this->queryRekursif($params);
			if(count($childs) > 0){
				$data[$a]['children'] = $childs;
				$data[$a]['leaf'] = false;
				$data[$a]['cls'] = 'folder';
			} else {
				$data[$a]['leaf'] = true;
				$data[$a]['cls'] = 'file';
			}
			$a++;
		}
		return $data;
	}

	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		foreach($data as &$entity) {
			$result = $this->referensi->load(['ID' => $entity['JENIS'], 'JENIS' => 74]);
			if(count($result) > 0) $entity['REFERENSI']['JENIS'] = $result[0];	
		}
		return $data;
	}
}
