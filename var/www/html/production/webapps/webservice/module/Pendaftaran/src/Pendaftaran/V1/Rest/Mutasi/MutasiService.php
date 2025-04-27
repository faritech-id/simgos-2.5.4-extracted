<?php
namespace Pendaftaran\V1\Rest\Mutasi;

use DBService\DatabaseService;
use Laminas\Db\Sql\Select;
use DBService\generator\Generator;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Expression;
use Zend\json\Json;
use DBService\System;
use DBService\Service;

use General\V1\Rest\Ruangan\RuanganService;
use General\V1\Rest\Referensi\ReferensiService;
use General\V1\Rest\Dokter\DokterService;
use Pendaftaran\V1\Rest\Pendaftaran\PendaftaranService;
use Pendaftaran\V1\Rest\Kunjungan\KunjunganService;
use Pendaftaran\V1\Rest\Reservasi\ReservasiService;

class MutasiService extends Service
{   
	private $dpjp;

	protected $references = [
		'Ruangan' => true,
		'Referensi' => true,
		'Kunjungan' => true,
		'Reservasi' => true,
		'DPJP' => true
	];
	
    public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "Pendaftaran\\V1\\Rest\\Mutasi\\MutasiEntity";
		$this->config["entityId"] = "NOMOR";
		$this->config["autoIncrement"] = false;
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("mutasi", "pendaftaran"));
		$this->entity = new MutasiEntity();
		
		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {			
			if($this->references['Ruangan']) $this->ruangan = new RuanganService();
			if($this->references['Referensi']) $this->referensi = new ReferensiService();
			if($this->references['Kunjungan']) $this->kunjungan = new KunjunganService();
			if($this->references['Reservasi']) $this->reservasi = new ReservasiService();
			if($this->references['DPJP']) $this->dpjp = new DokterService();
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

					if($entity["IKUT_IBU"] == 1) {
					    if(is_object($this->references['Kunjungan'])) {
					        $references = isset($this->references['Kunjungan']->REFERENSI) ? (array) $this->references['Kunjungan']->REFERENSI : [];
					        $this->kunjungan->setReferences($references, true);
					        if(isset($this->references['Kunjungan']->COLUMNS)) $this->kunjungan->setColumns((array) $this->references['Kunjungan']->COLUMNS);
					    }
					    $kunjungan = $this->kunjungan->load(['kunjungan.NOMOR' => $entity['KUNJUNGAN_IBU']]);
					    if(count($kunjungan) > 0) $entity['REFERENSI']['KUNJUNGAN_IBU'] = $kunjungan[0];
					}
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
				if($this->references['Reservasi']) {
					$reservasi = $this->reservasi->load(['NOMOR' => $entity['RESERVASI']]);
					if(count($reservasi) > 0) $entity['REFERENSI']['RESERVASI'] = $reservasi[0];
				}
				if($this->references['DPJP']) {
					$dpjp = $this->dpjp->load(['ID' => $entity['DPJP']]);
					if(count($dpjp) > 0) $entity['REFERENSI']['DPJP'] = $dpjp[0];
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
			if(count($kjgn) > 0) {
				$nomor = Generator::generateNoMutasi($kjgn[0]['RUANGAN']);			
				$this->entity->set('NOMOR', $nomor);
			}
		}
	}	

	public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;
		$this->entity->exchangeArray($data);		
		$nomor = is_numeric($this->entity->get('NOMOR')) ? $this->entity->get('NOMOR') : false;
		$success = true;
		
		if($nomor) {
			$_data = $this->entity->getArrayCopy();
			$this->table->update($_data, ["NOMOR" => $nomor]);
		} else {
			$kjgn = $this->kunjungan->load(['kunjungan.NOMOR' => $this->entity->get('KUNJUNGAN')]);
			if(count($kjgn) > 0) {
				$nomor = Generator::generateNoMutasi($kjgn[0]['RUANGAN']);
				
				$this->entity->set('NOMOR', $nomor);
				$_data = $this->entity->getArrayCopy();
				$this->table->insert($_data);
			} else $success = false;
		}
				
		return [
			'success' => $success,
			'data' => $success ? $this->load(['mutasi.NOMOR' => $nomor]) : null
		];
	}
	
	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'NOMOR')) {
			$nomor = $params['NOMOR'];
			$params['mutasi.NOMOR'] = $nomor;
			unset($params['NOMOR']);
		}
		
		if(!System::isNull($params, 'STATUS')) {
			$params['mutasi.STATUS'] = !is_array($params['STATUS']) ? (strpos(strval($params['STATUS']), "]") > 0 ? (array) json_decode($params['STATUS']) : $params['STATUS']) : $params['STATUS'];
			unset($params['STATUS']);
		}
		
		if(!System::isNull($params, 'ASAL')) {
			$asal = $params['ASAL'];
			$params['kjgn.RUANGAN'] = $asal;
			unset($params['ASAL']);
		}
		
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
			$select->where->between("mutasi.TANGGAL", $tanggal." 00:00:00", $tanggal." 23:59:59");
			unset($params['TANGGAL']);
		}
		
		if($this->user && $this->privilage) {
			$usr = $this->user;
			$histori = false;
			//$select->where("EXISTS(SELECT 1 FROM aplikasi.pengguna_akses_ruangan par WHERE par.RUANGAN IN (mutasi.TUJUAN, kjgn.RUANGAN) AND par.STATUS = 1 AND par.PENGGUNA = ".$usr.")");	
			$join = "par.RUANGAN = mutasi.TUJUAN";
			if(!System::isNull($params, 'HISTORY')) {
				$join = "(par.RUANGAN = mutasi.TUJUAN OR par.RUANGAN = kjgn.RUANGAN)";
				$histori = true;
				unset($params['HISTORY']);
			} else {
				if(!System::isNull($params, 'KUNJUNGAN')) $join = "par.RUANGAN = kjgn.RUANGAN";
			}
			$select->join(["par" => new Expression(
				"(SELECT DISTINCT par.RUANGAN
				FROM aplikasi.pengguna_akses_ruangan par
					 INNER JOIN `master`.ruangan r 
			   WHERE par.STATUS = 1 
				 AND par.PENGGUNA = $usr
				 AND r.ID = par.RUANGAN ".
				 (!$histori ? "AND r.JENIS_KUNJUNGAN = 3 " : "")."
				 AND r.JENIS = 5)")],
				 $join,
				[]
			);
		}
	}
	
	public function kunjunganSudahDimutasikan($kunjungan) {
	    $found = $this->load([
	        "KUNJUNGAN" => $kunjungan,
	        "STATUS" => [1,2]
	    ]);
	    return count($found) > 0;
	}

	public function getKunjungan() {
		if($this->includeReferences) {
			if($this->references['Kunjungan']) return $this->kunjungan;
		}	
		
		return null;
	}
}