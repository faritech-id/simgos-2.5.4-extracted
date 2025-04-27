<?php
namespace General\V1\Rest\Dokter;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;
use General\V1\Rest\DokterRuangan\DokterRuanganService;
use General\V1\Rest\DokterSMF\DokterSMFService;
use General\V1\Rest\Pegawai\PegawaiService;
use General\V1\Rest\Referensi\ReferensiService;

class DokterService extends Service
{
    private $dokterRuangan;
	private $dokterSMF;
	private $pegawai;
	private $referensi;
    
    public function __construct() {
		$this->config["entityName"] = "General\\V1\\Rest\\Dokter\\DokterEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("dokter", "master"));
		$this->entity = new DokterEntity();
		$this->dokterRuangan = new DokterRuanganService(true, ['Dokter' => false]);	
		$this->dokterSMF = new DokterSMFService();
		$this->pegawai = new PegawaiService();
		$this->referensi = new ReferensiService();
        
        $this->limit = 1000;
    }

	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		$dokters = [];
		$i = 0;
		foreach($data as $entity) {
			$pegawai = $this->pegawai->load(["NIP" => $entity['NIP']]);
			$smf = [];
			$nama = "";
			if(count($pegawai) > 0) {
				if(str_replace(' ','', $pegawai[0]['GELAR_DEPAN']) != '') $titik = '. ';
				else $titik = '';

				if(str_replace(' ','', $pegawai[0]['GELAR_BELAKANG']) != '') $koma = ', ';
				else $koma = '';

				$nama = $pegawai[0]['GELAR_DEPAN'].$titik.$pegawai[0]['NAMA'].$koma.$pegawai[0]['GELAR_BELAKANG'];
				
				$dokters[$i]['ID'] = $entity['ID'];
				$dokters[$i]['NAMA'] = $nama;
				$dokters[$i]['NIP'] = $entity['NIP'];

				if(!empty($pegawai[0]['KARTU_IDENTITAS'])) $dokters[$i]["REFERENSI"]["KARTU_INDETITAS"] = $pegawai[0]['KARTU_IDENTITAS'];
				if(!empty($pegawai[0]['KONTAKS'])) $dokters[$i]["REFERENSI"]["KONTAKS"] = $pegawai[0]['KONTAKS'];

				$smf = $this->referensi->load(["ID" => $pegawai[0]["SMF"], "JENIS" => 26]);
				if(count($smf) > 0) $dokters[$i]["REFERENSI"]["SMF"] = $smf[0];
				$i++;
			}
		}
		
		return $dokters;
	}      
	
	public function cariDokter($params = []) {
		$params = is_array($params) ? $params : (array) $params;					
		$dokters = [];
		$i = 0;
		$_params = [
			'RUANGAN' => isset($params['RUANGAN']) ? $params['RUANGAN'] : "", 
			'STATUS' => 1
		];
		if(isset($params['NIP'])) $_params["NIP"] = $params['NIP'];
		if(isset($params['RUANGAN']) && isset($params['SMF'])) {
			$druangans = $this->dokterRuangan->load($_params);
			foreach ($druangans as $dr) {
				$dsmfs = $this->dokterSMF->load(['SMF'=>$params['SMF'], "STATUS" => 1]);
				foreach ($dsmfs as $dsmf) {
					if($dsmf['DOKTER'] == $dr['DOKTER']) {
						$doks = $this->load(['ID'=>$dsmf['DOKTER'], "STATUS" => 1]);						
						if(count($doks) > 0) {
							$dokters[$i] = $doks[0];
							$i++;
						}
					}
				}
			}
		} else {
			if(isset($params['RUANGAN']))
				$data = $this->dokterRuangan->load($_params);
			else if(isset($params['SMF']))
				$data = $this->dokterSMF->load(['SMF'=>$params['SMF'], "STATUS" => 1]);
							
			foreach ($data as $d){
				$search = [
					'ID'=>$d['DOKTER'],
					"STATUS" => 1
				];
				if(isset($params['QUERY'])) $search['QUERY'] = $params['QUERY'];
				$doks = $this->load($search);
				if(count($doks) > 0) {
					$dokters[$i] = $doks[0];
					$i++;
				}
			}	
		}
		
		return $dokters;
    }

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'ID')) {				
			$params["dokter.ID"] = $params["ID"];
			unset($params["ID"]);
		}
		
		if(!System::isNull($params, 'NAMA')) { 
			$select->join(
				['p' => new TableIdentifier("pegawai", "master")], 
				"dokter.NIP = p.NIP",
				["NIP", "NAMA", "GELAR_DEPAN", "GELAR_BELAKANG"]
			);
			$select->where->like('p.NAMA', '%'.$params['NAMA'].'%');
			unset($params['NAMA']);
		}
		
		if(!System::isNull($params, 'STATUS')) {
			$params['dokter.STATUS'] = $params['STATUS'];
			unset($params['STATUS']);
		}
		
		if(isset($params['QUERY'])) {
			if(!System::isNull($params, 'QUERY')) {
				$select->join(
					['p' => new TableIdentifier("pegawai", "master")], 
					"dokter.NIP = p.NIP", 
					["NIP", "NAMA", "GELAR_DEPAN", "GELAR_BELAKANG"]
				);
				$params[] = new \Laminas\Db\Sql\Predicate\Expression("(p.NAMA LIKE ? OR p.NIP LIKE ?)", ["%".$params["QUERY"]."%", $params["QUERY"]."%"]);
				unset($params['QUERY']);
			}
		}
	}
		
	private function namaPegawai($nip){
		$peg = $this->pegawai->load(['NIP' => $nip], ["NIP", "NAMA", "GELAR_DEPAN", "GELAR_BELAKANG"]);
		
		if(count($peg) == 0) return '';

		if(str_replace(' ','', $peg[0]['GELAR_DEPAN']) != '') $titik = '. ';
		else $titik = '';

		if(str_replace(' ','', $peg[0]['GELAR_BELAKANG']) != '') $koma = ', ';
		else $koma = '';

		return $peg[0]['GELAR_DEPAN'].$titik.$peg[0]['NAMA'].$koma.$peg[0]['GELAR_BELAKANG'];
	}
}