<?php
namespace Pendaftaran\V1\Rest\Konsul;

use DBService\DatabaseService;
use Laminas\Db\Sql\Select;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Expression;
use DBService\generator\Generator;
use Zend\json\Json;
use DBService\System;
use DBService\Service;

use General\V1\Rest\Ruangan\RuanganService;
use General\V1\Rest\Referensi\ReferensiService;
use General\V1\Rest\Dokter\DokterService;
use Pendaftaran\V1\Rest\Kunjungan\KunjunganService;

class KonsulService extends Service
{   
	protected $references = [
		'Ruangan' => true,
		'Referensi' => true,
		'Dokter' => true,
		'Kunjungan' => true
	];
	
    public function __construct($includeReferences = true, $references = []) {
        $this->config["entityName"] = "Pendaftaran\\V1\\Rest\\Konsul\\KonsulEntity";
		$this->config["entityId"] = "NOMOR";
		$this->config["autoIncrement"] = false;
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("konsul", "pendaftaran"));
		$this->entity = new KonsulEntity();
		
		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {
			if($this->references['Ruangan']) $this->ruangan = new RuanganService();
			if($this->references['Referensi']) $this->referensi = new ReferensiService();
			if($this->references['Dokter']) $this->dokter = new DokterService();
			if($this->references['Kunjungan']) $this->kunjungan = new KunjunganService();
		}
    }
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		
		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['Kunjungan']) {
					if(is_object($this->references['Kunjungan'])) {
						$references = isset($this->references['Kunjungan']->REFERENSI) ? (array) $this->references['Kunjungan']->REFERENSI : [];
						$this->kunjungan->setReferences($references, true);
						if(isset($this->references['Kunjungan']->COLUMNS)) $this->kunjungan->setColumns((array) $this->references['Kunjungan']->COLUMNS);
					}
					$kunjungan = $this->kunjungan->load(['kunjungan.NOMOR' => $entity['KUNJUNGAN']]);
					if(count($kunjungan) > 0) $entity['REFERENSI']['KUNJUNGAN'] = $kunjungan[0];
				}
				if($this->references['Ruangan']) {
					if(is_object($this->references['Ruangan'])) {
						$references = isset($this->references['Ruangan']->REFERENSI) ? (array) $this->references['Ruangan']->REFERENSI : [];
						$this->ruangan->setReferences($references, true);
						if(isset($this->references['Ruangan']->COLUMNS)) $this->ruangan->setColumns((array) $this->references['Ruangan']->COLUMNS);
					}
					$ruangan = $this->ruangan->load(['ID' => $entity['TUJUAN']]);
					if(count($ruangan) > 0) $entity['REFERENSI']['TUJUAN'] = $ruangan[0];
				}
				if($this->references['Dokter']) {
					$dokter = $this->dokter->load(['ID' => $entity['DOKTER_ASAL']]);
					if(count($dokter) > 0) $entity['REFERENSI']['DOKTER_ASAL'] = $dokter[0];
				}
				if($this->references['Referensi']) {
					$referensi = $this->referensi->load(['JENIS' => 31,'ID' => $entity['STATUS']]);
					if(count($referensi) > 0) $entity['REFERENSI']['STATUS'] = $referensi[0];
				}
			}
		}
		
		return $data;
	}
	
	protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
		if($isCreated) {
			$kjgn = $this->kunjungan->load(['kunjungan.NOMOR' => $this->entity->get('KUNJUNGAN')]);
			if(count($kjgn) > 0) $entity->set("NOMOR", Generator::generateNoKonsul($kjgn[0]['RUANGAN']));
		}
	}
	
	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'STATUS')) {
			$params['konsul.STATUS'] = !is_array($params['STATUS']) ? (strpos(strval($params['STATUS']), "]") > 0 ? (array) json_decode($params['STATUS']) : $params['STATUS']) : $params['STATUS'];
			unset($params['STATUS']);
		}
		
		if(!System::isNull($params, 'NOMOR')) {
			$nomor = $params['NOMOR'];
			$params['konsul.NOMOR'] = $nomor;
			unset($params['NOMOR']);
		}
		
		if(!System::isNull($params, 'ASAL')) {
			$asal = $params['ASAL'];
			$params['kjgn.RUANGAN'] = $asal;
			unset($params['ASAL']);
		}
		
		$select->join(
			['r' => new TableIdentifier('ruangan', 'master')],
			'r.ID = konsul.TUJUAN',
			['JENIS_KUNJUNGAN']
		);
		
		$select->join(
			['kjgn' => new TableIdentifier('kunjungan', 'pendaftaran')],
			'kjgn.NOMOR = KUNJUNGAN',
			[]
		);
		
		$select->join(
			['p' => new TableIdentifier('pendaftaran', 'pendaftaran')],
			'p.NOMOR = kjgn.NOPEN',
			[]
		);
		
		if(!System::isNull($params, 'TANGGAL')) {
			$tanggal = substr($params['TANGGAL'], 0, 10);
			$select->where->between("konsul.TANGGAL", $tanggal." 00:00:00", $tanggal." 23:59:59");
			unset($params['TANGGAL']);
		}
		
		if($this->user && $this->privilage) {
			$usr = $this->user;
			$join = "par.RUANGAN = konsul.TUJUAN";
			if(!System::isNull($params, 'HISTORY')) {
				$join = "(par.RUANGAN = konsul.TUJUAN OR par.RUANGAN = kjgn.RUANGAN)";
				unset($params['HISTORY']);
			}
			$select->join(["par" => new Expression(
				"(SELECT DISTINCT par.RUANGAN
				FROM aplikasi.pengguna_akses_ruangan par
					 INNER JOIN `master`.ruangan r 
			   WHERE par.STATUS = 1 
				 AND par.PENGGUNA = $usr
				 AND r.ID = par.RUANGAN
				 AND r.JENIS = 5)")],
				 $join,
				[]
			);
			//$select->where("EXISTS(SELECT 1 FROM aplikasi.pengguna_akses_ruangan par WHERE par.RUANGAN = kjgn.RUANGAN AND par.PENGGUNA = ".$usr." AND par.STATUS = 1)");
		}
	}

	public function kunjunganSudahDikonsulkan($kunjungan) {
	    $found = $this->load([
	        "KUNJUNGAN" => $kunjungan,
	        "STATUS" => [1,2]
	    ]);
	    return count($found) > 0;
	}
}