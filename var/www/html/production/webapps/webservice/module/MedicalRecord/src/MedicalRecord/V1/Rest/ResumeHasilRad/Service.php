<?php
namespace MedicalRecord\V1\Rest\ResumeHasilRad;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service as DBService;

class Service extends DBService {
	
	public function __construct($includeReferences = true /* $references = array() */) {
		$this->config["entityName"] = "MedicalRecord\\V1\\Rest\\ResumeHasilRad\\ResumeHasilRadEntity";
		$this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("listHasilRad", "medicalrecord"));
		$this->entity = new ResumeHasilRadEntity();

		/* $this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {
			if($this->references['Kunjungan']) $this->kunjungan = new KunjunganService(true, [
				'Ruangan' => true,
				'Referensi' => false,
				'Pendaftaran' => true,
				'RuangKamarTidur' => false,
				'PasienPulang' => false,
				'Pembatalan' => false,
				'Perujuk' => false,
				'Mutasi' => false
			]);
			if($this->references['Tujuan']) $this->tujuan = new ReferensiService();
			if($this->references['Dokter']) $this->dokter = new DokterService(); 
		} */
	}
	
	public function listHasilRad($nopen) {
		$adapter = DatabaseService::get('SIMpel')->getAdapter(); 
		$stmt = $adapter->query('CALL medicalrecord.listHasilRad(?)');
		$results = $stmt->execute(array($nopen));
		$data = array();
		
		foreach($results as $row) {
			$data[] = $row;
		}
		
		try {
			$results->getResource()->closeCursor();
		} catch(\Exception $e) {
		}
		
		return $data;
		
	}
}