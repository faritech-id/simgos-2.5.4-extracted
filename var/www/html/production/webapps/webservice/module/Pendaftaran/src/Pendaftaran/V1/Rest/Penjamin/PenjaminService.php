<?php
namespace Pendaftaran\V1\Rest\Penjamin;

use General\V1\Rest\Referensi\ReferensiService;
use General\V1\Rest\KAP\KAPService;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;
use General\V1\Rest\TarifFarmasiPerKelas\TarifFarmasiPerKelasService;
use General\V1\Rest\JenisPesertaPenjamin\Service as JenisPesertaPenjaminService;
use Pendaftaran\V1\Rest\Pendaftaran\PendaftaranService;
use BPJService\db\peserta\Service as bpjsKepesertaanService;

class PenjaminService extends Service
{
	private $referensi;
	private $kap;
	private $tariffarmasiperkelas;
	private $jenisPeserta;
	private $pendaftaran;
	private $kepesertaan;
	
	protected $references = [
		'Kelas' => true,
		'Pembayaran' => true,
		'TarifFarmasi' => true,		
		'KAP' => true,
		'JenisPeserta' => true,
		'Pendaftaran' => true,
		'Kepesertaan' => true
	];

    public function __construct($includeReferences = true, $references = []) {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("penjamin", "pendaftaran"));
		$this->entity = new PenjaminEntity();
		
		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {
			$this->referensi = new ReferensiService();
			if($this->references['Pendaftaran']) $this->pendaftaran = new PendaftaranService(true, [
				'Pasien' => true,		
				'TujuanPasien' => true,
				'SuratRujukanPasien' => true,
				'Penjamin' => false,
				'DiagnosaMasuk' => true,
				'Referensi' => true,
				'KAP' => true,
				'PasienPulang' => true,
				'PasienMeninggal' => true,
				'Kecelakaan' => true,
				'PenanggungJawabPasien' => true,
				'Kunjungan' => true,
				'TindakanMedis' => true,
				'Pengantar' => true,
				'Inacbg' => true,
			]);
			if($this->references['KAP']) $this->kap = new KAPService();
			if($this->references['TarifFarmasi']) $this->tariffarmasiperkelas = new TarifFarmasiPerKelasService();
			if($this->references['JenisPeserta']) $this->jenisPeserta = new JenisPesertaPenjaminService();	
			if($this->references['Kepesertaan']) $this->kepesertaan = new bpjsKepesertaanService();			
		}	
    }
	
	public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;
		$norm = 0;
		$cek = $this->table->select(["NOPEN" => $data['NOPEN']])->toArray(); 
		if(count($cek) > 0) {
			if(!isset($data['JENIS'])) $data['JENIS'] = $cek[0]['JENIS'];
		}
		if(isset($data['NORM'])) {
			$norm = $data['NORM'];
			$this->simpanKAP($data);
			unset($data["NOMOR"]);
		}	
		$this->entity->exchangeArray($data);
		if(isset($data['SEP'])) {
			$this->entity->set('NOMOR', $data['SEP']);
		} else {
			$this->entity->set('NOMOR', "");
		}
		$nopen = $this->entity->get('NOPEN');
		
		if(count($cek) > 0 ) {
			$this->table->update($this->entity->getArrayCopy(), ["NOPEN" => $nopen]);
		} else {
			$this->table->insert($this->entity->getArrayCopy());
		}
		
		$data = $norm == 0 ? $this->load(['NOPEN' => $nopen]) : $this->load(['NOPEN' => $nopen, 'NORM' => $norm]);
		
		return $data;
	}
	
	public function simpanKAP($data) {
	    if(isset($data['NOMOR'])) {
	        $params = [
	            'JENIS'=>$data['JENIS'],
	            'NORM'=>$data['NORM'],
	            'NOMOR'=>$data['NOMOR']
			];
	        
	        $this->kap->simpanData($params);
	    }
	}
	
	public function getRowCount($params = []) {
		$norm = isset($params['NORM']) ? $params['NORM'] : null;
		if($norm || empty($norm)) unset($params['NORM']);
		
		return parent::getRowCount($params);
	}
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$norm = isset($params['NORM']) ? $params['NORM'] : null;
		if(isset($norm) || empty($norm)) unset($params['NORM']);
		
		$data = parent::load($params, $columns, $orders);
		
		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['Kelas']) {
					$kelas = $this->referensi->load(['JENIS' => 19, 'ID' => $entity['KELAS']]);
					if(count($kelas) > 0) $entity['REFERENSI']['KELAS'] = $kelas[0];
				}
				
				if($this->references['Pendaftaran']) {
					$pendaftaran = $this->pendaftaran->load(['NOMOR' => $entity['NOPEN']]);
					if(count($pendaftaran) > 0) $entity['REFERENSI']['PENDAFTARAN'] = $pendaftaran[0];
				}

				if($this->references['Pembayaran']) {
					$pembayaran = $this->referensi->load(['JENIS' => 34, 'ID' => $entity['JENIS']]);
					if(count($pembayaran) > 0) $entity['REFERENSI']['PEMBAYARAN'] = $pembayaran[0];
				}
				
				if($this->references['TarifFarmasi']) {
					$tariffarmasiperkelas = $this->tariffarmasiperkelas->load(['KELAS' => $entity['KELAS'], 'STATUS' => 1]);
					if(count($tariffarmasiperkelas) > 0) $entity['REFERENSI']['TARIF_FARMASI'] = $tariffarmasiperkelas[0];
				}
				
				if($this->references['KAP']) {
					if(isset($norm)) {
						$kap = $this->kap->load(['JENIS' => $entity['JENIS'], 'NORM' => $norm]);
						if(count($kap) > 0) $entity['REFERENSI']['KAP'] = $kap[0];
					}
				}

				if($this->references['JenisPeserta']) {
					$jenisPeserta = $this->jenisPeserta->load(['JENIS' => $entity['JENIS'], 'ID' => $entity['JENIS_PESERTA']]);
					if(count($jenisPeserta) > 0) $entity['REFERENSI']['JENIS_PESERTA'] = $jenisPeserta[0];
				}

				if($this->references['Kepesertaan']) {
					if(isset($norm) && $entity['JENIS'] == 2) {
						$kepesertaan = $this->kepesertaan->load(['norm' => $norm]);
						if(count($kepesertaan) > 0) $entity['REFERENSI']['KEPESERTAAN'] = $kepesertaan[0];
					}
				}

				$ref = $this->referensi->load(['JENIS' => 10, 'ID' => $entity['JENIS']]);
				if(count($ref) > 0) $entity['REFERENSI']['JENIS_PENJAMIN'] = $ref[0];
			}
		}
		
		return $data;
	}
}