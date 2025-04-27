<?php
namespace Layanan\V1\Rest\HasilLab;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;
use Laminas\Db\Sql\Select;
use DBService\generator\Generator;
use General\V1\Rest\ParameterTindakanLab\ParameterTindakanLabService;
use Layanan\V1\Rest\TindakanMedis\TindakanMedisService;
use DBService\System;

class HasilLabService extends Service
{
	private $parameterhasil;
	private $tindakanmedis;
	
	protected $references = [
		"ParameterHasil" => true,
		"TindakanMedis" =>  true
	];

    public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "Layanan\\V1\\Rest\\HasilLab\\HasilLabEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("hasil_lab", "layanan"));
		$this->entity = new HasilLabEntity();

		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;

		if($includeReferences) {
            if($this->references['ParameterHasil']) $this->parameterhasil = new ParameterTindakanLabService();
			if($this->references['TindakanMedis']) $this->tindakanmedis = new TindakanMedisService();
        }
    }

	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		foreach($data as &$entity) {
            if($this->includeReferences){
                if($this->references['ParameterHasil']){ 
                    $parameterhasil = $this->parameterhasil->load(['ID' => $entity['PARAMETER_TINDAKAN']]);
                    if(count($parameterhasil) > 0) $entity['REFERENSI']['PARAMETER_TINDAKAN'] = $parameterhasil[0];
                }

				if($this->references['TindakanMedis']){
					if(is_object($this->references['TindakanMedis'])) {
						$references = isset($this->references['TindakanMedis']->REFERENSI) ? (array) $this->references['TindakanMedis']->REFERENSI : [];
						$this->tindakanmedis->setReferences($references, true);
						if(isset($this->references['TindakanMedis']->COLUMNS)) $this->tindakanmedis->setColumns((array) $this->references['TindakanMedis']->COLUMNS);
					}
                    $tindakanmedis = $this->tindakanmedis->load(['ID' => $entity['TINDAKAN_MEDIS']]);
                    if(count($tindakanmedis) > 0) $entity['REFERENSI']['TINDAKAN_MEDIS'] = $tindakanmedis[0];
                }
            }
		}
        	
		return $data;
	}

	protected function onBeforeSaveCallback($key, &$entity, &$data, $isCreated = false) {
		if($isCreated) $entity->set('ID', Generator::generateIdHasilLab());
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(isset($params["ID"])) {
			$params["hasil_lab.ID"] = $params["ID"];
			unset($params["ID"]);
		}
		
		if(!System::isNull($params, 'STATUS')) {
			$params['hasil_lab.STATUS'] = $params['STATUS'];
			unset($params['STATUS']);
		}

		$select->join(
			['t' => new TableIdentifier('tindakan_medis', 'layanan')],
			't.ID = hasil_lab.TINDAKAN_MEDIS',
			[]
		);

		$select->join(
			['mt' => new TableIdentifier('tindakan', 'master')],
			'mt.ID = t.TINDAKAN',
			[]
		);

		$select->join(
			['k' => new TableIdentifier('kunjungan', 'pendaftaran')],
			'k.NOMOR = t.KUNJUNGAN',
			[]
		);
		if(!System::isNull($params, 'NORM')) {
			$norm = $params['NORM'];
			$select->join(
				['pdftrn' => new TableIdentifier('pendaftaran', 'pendaftaran')],
				'pdftrn.NOMOR = k.NOPEN',
				[]
			);
			$select->where('pdftrn.NORM = '.$norm);
			unset($params['NORM']);
		}
		if(!System::isNull($params, 'NOPEN')) {
			$select->where(["k.NOPEN" => $params['NOPEN']]);
			unset($params['NOPEN']);
		}
		if(!System::isNull($params, 'KUNJUNGAN')) {
			$select->where(["k.NOMOR" => $params['KUNJUNGAN']]);
			unset($params['	']);
		}

		if(isset($params['TANGGAL'])) {
			if(!System::isNull($params, 'TANGGAL')) {
				$select->where->between('hasil_lab.TANGGAL', $params["TANGGAL"]." 00:00:00", $params["TANGGAL"]." 23:59:59");
				unset($params['TANGGAL']);
			}
		}

		if($this->user) {				
			$usr = $this->user;
			if(!$this->cekMemilikiaAksesLab()) $select->where('mt.PRIVACY = 0');
		}
	}

	public function cekMemilikiaAksesLab() {
		$result = $this->execute("SELECT aplikasi.aksesRuanganBerdasarkanJenis(?) ADA", [$this->user]);
		if(count($result) > 0) {
			if($result[0]["ADA"] == 'TRUE') return true;
		}
		
		return false;
	}
}