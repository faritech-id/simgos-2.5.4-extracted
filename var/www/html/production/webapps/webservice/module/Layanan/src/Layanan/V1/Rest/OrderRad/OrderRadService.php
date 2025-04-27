<?php
namespace Layanan\V1\Rest\OrderRad;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;
use Laminas\Db\Sql\Select;
use Laminas\Db\Sql\Expression;
use DBService\System;
use DBService\generator\Generator;
use General\V1\Rest\Ruangan\RuanganService;
use General\V1\Rest\Referensi\ReferensiService;
use General\V1\Rest\Dokter\DokterService;
use Layanan\V1\Rest\OrderDetilRad\OrderDetilRadService;
use Pendaftaran\V1\Rest\Kunjungan\KunjunganService;
use Aplikasi\V1\Rest\Pengguna\PenggunaService;

class OrderRadService extends Service
{	
	private $ruangan;
	private $referensi;
	private $detilrad;
	private $dokter;
	private $kunjungan;

	private $pengguna;
	
	protected $references = array(
		'Pendaftaran' => true,
		'Ruangan' => true,
		'Referensi' => true,
		'Dokter' => true,
		'OrderDetil' => true,
		'Kunjungan' => true
	);
	
    public function __construct($includeReferences = true, $references = array()) {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("order_rad", "layanan"));
		$this->entity = new OrderRadEntity();
		
		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {		
			if($this->references['Ruangan']) $this->ruangan = new RuanganService();
			if($this->references['Referensi']) $this->referensi = new ReferensiService();
			if($this->references['Dokter']) $this->dokter = new DokterService();
			if($this->references['OrderDetil']) $this->detilrad = new OrderDetilRadService();
			if($this->references['Kunjungan']) $this->kunjungan = new KunjunganService();
		}

		$this->pengguna = new PenggunaService();
    }
        
	public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;
		$this->entity->exchangeArray($data);
		
		$nomor = is_numeric($this->entity->get('NOMOR')) ? $this->entity->get('NOMOR') : false;
		if($nomor) {
			$_data = $this->entity->getArrayCopy();
			$this->table->update($_data, array("NOMOR" => $nomor, 'STATUS' => 1));
		} else {
			$kunjungan = $this->kunjungan->load(array('kunjungan.NOMOR' => $this->entity->get('KUNJUNGAN')));
			if(count($kunjungan) > 0) {
				$nomor = Generator::generateNoOrderRad($kunjungan[0]['RUANGAN']);
				$this->entity->set('NOMOR', $nomor);
			
				$_data = $this->entity->getArrayCopy();
				$this->table->insert($_data);
			}
		}
		
		$this->SimpanDetilRad($data, $nomor);
		
		return $this->load(array('order_rad.NOMOR' => $nomor));
	}
	
	private function SimpanDetilRad($data, $id) {
		if(isset($data['ORDER_DETIL'])) {
			
			foreach($data['ORDER_DETIL'] as $tgs) {
				$tgs['ORDER_ID'] = $id;
				$this->detilrad->simpan($tgs);
			}
		}
	}
	
	public function load($params = array(), $columns = array('*'), $orders = array()) {
		$data = parent::load($params, $columns, $orders);
		
		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['Kunjungan']) {
					if(is_object($this->references['Kunjungan'])) {
						$references = isset($this->references['Kunjungan']->REFERENSI) ? (array) $this->references['Kunjungan']->REFERENSI : array();
						$this->kunjungan->setReferences($references, true);
						if(isset($this->references['Kunjungan']->COLUMNS)) $this->kunjungan->setColumns((array) $this->references['Kunjungan']->COLUMNS);
					}
					$kunjungan = $this->kunjungan->load(array('kunjungan.NOMOR' => $entity['KUNJUNGAN']));
					if(count($kunjungan) > 0) $entity['REFERENSI']['KUNJUNGAN'] = $kunjungan[0];
				}
				if($this->references['Ruangan']) {
					if(is_object($this->references['Ruangan'])) {
						$references = isset($this->references['Ruangan']->REFERENSI) ? (array) $this->references['Ruangan']->REFERENSI : array();
						$this->ruangan->setReferences($references, true);
						if(isset($this->references['Ruangan']->COLUMNS)) $this->ruangan->setColumns((array) $this->references['Ruangan']->COLUMNS);
					}
					$ruangan = $this->ruangan->load(array('ID' => $entity['TUJUAN']));
					if(count($ruangan) > 0) $entity['REFERENSI']['TUJUAN'] = $ruangan[0];
				}
				if($this->references['Dokter']) {
					$dokter = $this->dokter->load(array('ID' => $entity['DOKTER_ASAL']));
					if(count($dokter) > 0) $entity['REFERENSI']['DOKTER_ASAL'] = $dokter[0];
				}
				if($this->references['Referensi']) {
					$referensi = $this->referensi->load(array('JENIS' => 31,'ID' => $entity['STATUS']));
					if(count($referensi) > 0) $entity['REFERENSI']['STATUS'] = $referensi[0];
				}
				if(!empty($entity['OLEH'])) {
					$pengguna = $this->pengguna->getPegawai($entity['OLEH']);
					if($pengguna) $entity['REFERENSI']['PETUGAS'] = $pengguna;
				}
			}
		}
		
		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'STATUS')) {
			$params['order_rad.STATUS'] = !is_array($params['STATUS']) ? (strpos(strval($params['STATUS']), "]") > 0 ? (array) json_decode($params['STATUS']) : $params['STATUS']) : $params['STATUS'];
			unset($params['STATUS']);
		}
		
		if(!System::isNull($params, 'NOMOR')) {
			$params['order_rad.NOMOR'] = $params['NOMOR'];
			unset($params['NOMOR']);
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
			if(!is_array($params["TANGGAL"])) {
				$tanggal = substr($params['TANGGAL'], 0, 10);
				$select->where->between("order_rad.TANGGAL", $tanggal." 00:00:00", $tanggal." 23:59:59");
			} else {
				$tanggal = $params["TANGGAL"]["VALUE"];
				$params["order_rad.TANGGAL"] = $tanggal;
			}
			unset($params['TANGGAL']);
		}
		
		if($this->user && $this->privilage) {
			$usr = $this->user;
			$histori = false;
			$join = "par.RUANGAN = order_rad.TUJUAN";
			if(!System::isNull($params, 'HISTORY')) {
				$join = "(par.RUANGAN = kjgn.RUANGAN)";
				$histori = true;
				unset($params['HISTORY']);
			}
			$select->join(["par" => new Expression(
				"(SELECT DISTINCT par.RUANGAN 
				FROM aplikasi.pengguna_akses_ruangan par
					 INNER JOIN `master`.ruangan r 
			   WHERE par.STATUS = 1 
				 AND par.PENGGUNA = $usr
				 AND r.ID = par.RUANGAN ".
				 (!$histori ? "AND r.JENIS_KUNJUNGAN = 5 " : "")."
				 AND r.JENIS = 5)")],
				 $join,
				[]
			);
		}
	}
	
	public function kunjunganSudahDiOrderRadkan($kunjungan) {
	    $found = $this->load([
	        "KUNJUNGAN" => $kunjungan,
	        "STATUS" => [1,2]
	    ]);
	    return count($found) > 0;
	}
}