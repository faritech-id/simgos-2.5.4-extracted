<?php
namespace General\V1\Rest\Staff;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;
use General\V1\Rest\StaffRuangan\StaffRuanganService;
use General\V1\Rest\Pegawai\PegawaiService;

class StaffService extends Service
{
    private $staffRuangan;
	private $pegawai;
    
	protected $references = [
		'StaffRuangan' => true,
		'Pegawai' => true
	];
	
	public function __construct($includeReferences = true, $references = []) {
         $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("staff", "master"));
		$this->entity = new StaffEntity();
		
		$this->limit = 3000;
		
		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {			
			if($this->references['Pegawai']) $this->pegawai = new PegawaiService();
			if($this->references['StaffRuangan']) $this->staffRuangan = new StaffRuanganService();			
		}
    }
   
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		$staffs = []; 
		$i = 0;
		foreach($data as $entity) {
			$staffs[$i]['ID'] = $entity['ID'];
			$staffs[$i]['NAMA'] = $this->namaPegawai($entity['NIP']);
			$staffs[$i]['NIP'] = $entity['NIP'];
			$i++;
		}
		
		return $staffs;
	}
	
	public function cariStaff($params = []) {
		$params = is_array($params) ? $params : (array) $params;					
		$staffs = [];
		$i = 0;
		
		if(isset($params['RUANGAN'])) {
			$data = $this->staffRuangan->load([
				"RUANGAN" => $params["RUANGAN"],
				"STATUS" => 1
			]);
		}
							
		foreach ($data as $d){
			$search = ['ID' => $d['PERAWAT']];
			if(isset($params['QUERY'])) $search['QUERY'] = $params['QUERY'];
			$search["STATUS"] = 1;
			$stfs = $this->load($search);
			if(count($stfs) > 0) {
				$staffs[$i] = $stfs[0];
				$i++;
			}
		}
		
		return $staffs;
    }

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'STATUS')) {
			$status = $params['STATUS'];
			$params['staff.STATUS'] = $status;
			unset($params['STATUS']);
		}

		if(!System::isNull($params, 'ID')) {				
			$params["staff.ID"] = $params["ID"];
			unset($params["ID"]);
		}
		
		if(!System::isNull($params, 'NAMA')) { 
			$select->join(['p' => new TableIdentifier("pegawai", "master")], "staff.NIP = p.NIP", ["NIP", "NAMA", "GELAR_DEPAN", "GELAR_BELAKANG"]);
			$select->where->like('p.NAMA', '%'.$params['NAMA'].'%');
			unset($params['NAMA']);
		}
		
		if(isset($params['QUERY'])) if(!System::isNull($params, 'QUERY')) {
			$select->join(['p' => new TableIdentifier("pegawai", "master")], "staff.NIP = p.NIP", ["NIP", "NAMA", "GELAR_DEPAN", "GELAR_BELAKANG"]);
			$params[] = new \Laminas\Db\Sql\Predicate\Expression("(p.NAMA LIKE ? OR p.NIP LIKE ?)", ["%".$params["QUERY"]."%", $params["QUERY"]."%"]);
			unset($params['QUERY']);
		}
	}
	
	private function namaPegawai($nip){
		$peg = $this->pegawai->load(['NIP'=>$nip], ["NIP", "NAMA", "GELAR_DEPAN", "GELAR_BELAKANG"]);
		if(str_replace(' ','', $peg[0]['GELAR_DEPAN']) != ''){
			$titik = '. ';
		}else{
			$titik = '';
		}
		if(str_replace(' ','', $peg[0]['GELAR_BELAKANG']) != ''){
			$koma = ', ';
		}else{
			$koma = '';
		}
		return $peg[0]['GELAR_DEPAN'].$titik.$peg[0]['NAMA'].$koma.$peg[0]['GELAR_BELAKANG'];
	}
}