<?php
namespace Layanan\V1\Rest\HasilRad;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;
use Laminas\Db\Sql\Select;
use Laminas\Db\Sql\Expression;
use DBService\System;

use General\V1\Rest\Dokter\DokterService;
use Layanan\V1\Rest\TindakanMedis\TindakanMedisService;

class HasilRadService extends Service
{
	private $dokter;
	private $tindakanmedis;
	
    public function __construct() {
		$this->config["entityName"] = "Layanan\\V1\\Rest\\HasilRad\\HasilRadEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("hasil_rad", "layanan"));
		$this->entity = new HasilRadEntity();
		
		$this->dokter = new DokterService();
		$this->tindakanmedis = new TindakanMedisService();
    }
        
	protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
		$this->entity->set('TANGGAL', new \Laminas\Db\Sql\Expression('NOW()'));
	}
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		foreach($data as &$entity) {
			$dokter = $this->dokter->load(['ID' => $entity['DOKTER']]);
			if(count($dokter) > 0) $entity['REFERENSI']['DOKTER'] = $dokter[0];
			
			$tindakanmedis = $this->tindakanmedis->load(['ID' => $entity['TINDAKAN_MEDIS']]);
	        if(count($tindakanmedis) > 0) $entity['REFERENSI']['TINDAKAN_MEDIS'] = $tindakanmedis[0];
			$results = $this->parseReferensi($entity, "pengguna");
			if(count($results) > 0) $entity["REFERENSI"]["PENGGUNA"] = $results;
		}
		
		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(isset($params["ID"])) {
			$params["hasil_rad.ID"] = $params["ID"];
			unset($params["ID"]);
		}
		
		if(!System::isNull($params, 'STATUS')) {
			$status = $params['STATUS'];
			$params['hasil_rad.STATUS'] = $status;
			unset($params['STATUS']);
		}
		
		if(!System::isNull($params, 'NORM')) {
			$norm = $params['NORM'];

			$select->join(
				['t' => new TableIdentifier('tindakan_medis', 'layanan')],
				't.ID = hasil_rad.TINDAKAN_MEDIS',
				[]
			);

			$select->join(
				['k' => new TableIdentifier('kunjungan', 'pendaftaran')],
				'k.NOMOR = t.KUNJUNGAN',
				[]
			);
			$select->join(
				['pdftrn' => new TableIdentifier('pendaftaran', 'pendaftaran')],
				'pdftrn.NOMOR = k.NOPEN',
				[]
			);
			
			$select->where('pdftrn.NORM = '.$norm);
			unset($params['NORM']);
		}

		$select->join(
			['u' => new TableIdentifier('pengguna', 'aplikasi')],
			'u.ID = hasil_rad.OLEH',
			[]
		);
		
		$select->join(
			['p' => new TableIdentifier('pegawai', 'master')],
			'p.NIP = u.NIP',
			['pengguna_GELAR_DEPAN' => 'GELAR_DEPAN', 'pengguna_NAMA' => 'NAMA', 'pengguna_GELAR_BELAKANG' => 'GELAR_BELAKANG'],
			Select::JOIN_LEFT
		);

		if(isset($params['TANGGAL'])) {
			if(!System::isNull($params, 'TANGGAL')) {
				$select->where->between("hasil_rad.TANGGAL", $params["TANGGAL"]." 00:00:00", $params["TANGGAL"]." 23:59:59");
				unset($params['TANGGAL']);
			}
		}
		
		if(isset($params['HASIL_RAD'])) {
			if(!System::isNull($params, 'HASIL_RAD')) {
				$select->where("(hasil_rad.ID = '".$params['HASIL_RAD']."')");
				
				unset($params['HASIL_RAD']);
				
			}
		}
	}

	public function getDeskripsi($tindakanMedis) {
        $adapter = $this->table->getAdapter();
		$conn = $adapter->getDriver()->getConnection();
	    $result = $conn->execute("SELECT layanan.getDeskripsiHasilRad('".$tindakanMedis."') DESKRIPSI");
        $data = $result->current();
        return $data["DESKRIPSI"];
    }
	
	public function getDataBerkasKlaimObatRadiologi($data){
		$adapter = $this->table->getAdapter();
		if (isset($data->TINDAKAN_DESKRIPSI)) {
			$strLmt = $adapter->query("SELECT hr.*, td.NAMA
									FROM pendaftaran.pendaftaran a, pendaftaran.kunjungan k, layanan.tindakan_medis tm, master.ruangan r, layanan.hasil_rad hr, master.tindakan td
									WHERE a.NOMOR = k.NOPEN AND k.NOMOR = tm.KUNJUNGAN AND k.RUANGAN = r.ID AND tm.ID = hr.TINDAKAN_MEDIS
									AND NORM=? AND DATE(a.TANGGAL) <= ? AND r.JENIS_KUNJUNGAN=5 AND r.JENIS= 5 AND r.STATUS = 1
									AND td.ID = tm.TINDAKAN AND td.NAMA LIKE '".$data->TINDAKAN_DESKRIPSI."%'");
			$results = $strLmt->execute(array($data->NORM,$data->TANGGAL));
		}
		else {
			$strLmt = $adapter->query("SELECT hr.*
										FROM pendaftaran.pendaftaran a, pendaftaran.kunjungan k, layanan.tindakan_medis tm, master.ruangan r, layanan.hasil_rad hr
										WHERE a.NOMOR = k.NOPEN AND k.NOMOR = tm.KUNJUNGAN AND k.RUANGAN = r.ID AND tm.ID = hr.TINDAKAN_MEDIS
										AND NORM=? AND DATE(a.TANGGAL) <= ? AND r.JENIS_KUNJUNGAN=5 AND r.JENIS= 5 AND r.STATUS = 1");
			
			$results = $strLmt->execute(array($data->NORM,$data->TANGGAL));
		}
		$data = array();
		if(count($results) > 0){
			foreach($results as $row) {
				
				
				$dokters = $this->dokter->load(['ID' => $row['DOKTER']]);
				if(count($dokters) > 0) $row['REFERENSI']['DOKTER'] = $dokters[0];
				
				$tindakanmediss = $this->tindakanmedis->load(['ID' => $row['TINDAKAN_MEDIS']]);
				if(count($tindakanmediss) > 0) $row['REFERENSI']['TINDAKAN_MEDIS'] = $tindakanmediss[0];
				
				$data[] = $row;
			}
			return $data;
		} else {
			return $data;
		}
	}
}