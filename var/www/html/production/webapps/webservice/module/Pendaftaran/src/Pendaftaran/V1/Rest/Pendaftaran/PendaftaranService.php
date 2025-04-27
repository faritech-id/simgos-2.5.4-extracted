<?php
namespace Pendaftaran\V1\Rest\Pendaftaran;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\generator\Generator;
use Zend\json\Json;
use DBService\System;
use DBService\Service;

use General\V1\Rest\Pasien\PasienService;
use General\V1\Rest\KAP\KAPService;
use Pendaftaran\V1\Rest\PenanggungJawabPasien\PenanggungJawabPasienService;
use Pendaftaran\V1\Rest\TujuanPasien\TujuanPasienService;
use Pendaftaran\V1\Rest\SuratRujukanPasien\SuratRujukanPasienService;
use Pendaftaran\V1\Rest\Penjamin\PenjaminService;
use General\V1\Rest\DiagnosaMasuk\DiagnosaMasukService;
use General\V1\Rest\Referensi\ReferensiService;
use General\V1\Rest\Paket\PaketService;
use Layanan\V1\Rest\PasienPulang\PasienPulangService;
use Layanan\V1\Rest\PasienMeninggal\PasienMeninggalService;
use Pendaftaran\V1\Rest\Kecelakaan\Service as KecelakaanService;
use Pendaftaran\V1\Rest\Kunjungan\KunjunganService;
use Layanan\V1\Rest\TindakanMedis\TindakanMedisService;
use Pendaftaran\V1\Rest\PengantarPasien\Service as PengantarPasienService;
use INACBGService\V1\Rest\HasilGrouping\HasilGroupingService;
use MedicalRecord\V1\Rest\ICD10\ICD10Service; 

class PendaftaranService extends Service
{
	private $pasien;
    private $penanggungjawab;
	private $tujuanpasien;
	private $suratrujukanpasien;
	private $penjamin;
	private $diagnosa;
	private $referensi;
	private $kap;
	private $paket;
	private $pasienPulang;
	private $pasienmeninggal;
	private $kecelakaan;
	private $kunjungan;
	private $tindakanmedis;
	private $pengantar;
	private $inacbg;
	private $diagnosautama;

	protected $references = [
		'Pasien' => true,		
		'TujuanPasien' => true,
		'SuratRujukanPasien' => true,
		'Penjamin' => true,
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
		'DiagnosaUtama' => true
	];
    
    public function __construct($includeReferences = true, $references = []) {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("pendaftaran", "pendaftaran"));
		$this->entity = new PendaftaranEntity();
		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {
			if($this->references['Pasien']) $this->pasien = new PasienService(true, [
				'KeluargaPasien' => false,
				'KIP' => true,
				'KAP' => true,
				'KontakPasien' => true,
				'TempatLahir' => true,
				'Referensi' => true
			]); 
			if($this->references['TujuanPasien']) $this->tujuanpasien = new TujuanPasienService(true, ['Pendaftaran' => false]);
			if($this->references['SuratRujukanPasien']) $this->suratrujukanpasien = new SuratRujukanPasienService(true, ["DiagnosaMasuk" => true]);
			if($this->references['Penjamin']) $this->penjamin = new PenjaminService(true, [
				'Kelas' => true,
				'Pembayaran' => true,
				'TarifFarmasi' => true,		
				'KAP' => true,
				'JenisPeserta' => true,
				'Pendaftaran' => false,
			]);
			if($this->references['DiagnosaMasuk']) $this->diagnosa = new DiagnosaMasukService();	
			if($this->references['DiagnosaUtama']) $this->diagnosautama = new ICD10Service();	
			if($this->references['PasienPulang']) $this->pasienPulang = new PasienPulangService();
			if($this->references['PasienMeninggal']) $this->pasienmeninggal = new PasienMeninggalService();
			if($this->references['Kecelakaan']) $this->kecelakaan = new KecelakaanService();
			if($this->references['Referensi']) {
				$this->referensi = new ReferensiService();
				$this->paket = new PaketService();
			}
			if($this->references['PenanggungJawabPasien']) $this->penanggungjawab = new PenanggungJawabPasienService(); 
			if($this->references['KAP']) $this->kap = new KAPService();
			if($this->references['Kunjungan']) $this->kunjungan = new KunjunganService(true, [
				'Ruangan' => true,
				'Referensi' => true,
				'Pendaftaran' => false,
				'RuangKamarTidur' => true,
				'PasienPulang' => false,
				'Pembatalan' => false,
				'Perujuk' => false,
				'Mutasi' => false,
				'RujukanKeluar' => false,
				'DPJP' => false,
				'DPJPPenjaminRs' => false
			]);
			if($this->references['TindakanMedis']) $this->tindakanmedis = new TindakanMedisService(false);
			if($this->references['Pengantar']) $this->pengantar = new PengantarPasienService();
			if($this->references['Inacbg']) $this->inacbg = new HasilGroupingService(false);
		}			
    }
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		if($this->includeReferences) {
			foreach($data as &$entity) {
				
				if($this->references['Pasien']) {
					if(is_object($this->references['Pasien'])) {
						$references = isset($this->references['Pasien']->REFERENSI) ? (array) $this->references['Pasien']->REFERENSI : [];
						$this->pasien->setReferences($references, true);
						if(isset($this->references['Pasien']->COLUMNS)) $this->pasien->setColumns((array) $this->references['Pasien']->COLUMNS);
					}
					$pasien = $this->pasien->load([
						'NORM'=>$entity['NORM']
					]);
					if(count($pasien) > 0) $entity['REFERENSI']['PASIEN'] = $pasien[0];
				}
				if($this->references['DiagnosaMasuk']) {
					$diagnosa = $this->diagnosa->load([
						'ID'=>$entity['DIAGNOSA_MASUK']
					]);
					if(count($diagnosa) > 0) $entity['DIAGNOSAMASUK'] = $diagnosa[0];
				}						

				if($this->references['TujuanPasien']) {
					if(is_object($this->references['TujuanPasien'])) {
						$references = isset($this->references['TujuanPasien']->REFERENSI) ? (array) $this->references['TujuanPasien']->REFERENSI : [];
						$this->tujuanpasien->setReferences($references, true);
						if(isset($this->references['TujuanPasien']->COLUMNS)) $this->tujuanpasien->setColumns((array) $this->references['TujuanPasien']->COLUMNS);
					}
					
					$tujuan = $this->tujuanpasien->load([
						'NOPEN'=>$entity['NOMOR']
					]);
					if(count($tujuan) > 0) {
						$entity['TUJUAN'] = $tujuan[0];

						if(isset($tujuan[0]["REFERENSI"]["RUANGAN"])) {
							$rgn = $tujuan[0]["REFERENSI"]["RUANGAN"];
							if($rgn["JENIS_KUNJUNGAN"] == 3) {
								if($this->references['Kunjungan']) {
									$result = $this->kunjungan->load(['NOPEN' => $entity['NOMOR'], "JENIS_KUNJUNGAN" => "3", new \Laminas\Db\Sql\Predicate\In("kunjungan.STATUS", [1,2]), new \Laminas\Db\Sql\Predicate\Expression("kunjungan.REF IS NULL"), "start" => 0, "limit" => 1], ["*"], ["MASUK ASC"]);
									if(count($result) > 0) $entity['REFERENSI']['KUNJUNGAN_MASUK'] = $result[0];

									$result = $this->kunjungan->load(['NOPEN' => $entity['NOMOR'], "JENIS_KUNJUNGAN" => "3", new \Laminas\Db\Sql\Predicate\In("kunjungan.STATUS", [1,2]), "start" => 0, "limit" => 1], ["*"], ["MASUK DESC"]);
									if(count($result) > 0) $entity['REFERENSI']['KUNJUNGAN_KELUAR'] = $result[0];					
								}
							}
						}
					}
				}

				if($this->references['SuratRujukanPasien']) {
					$rujukan = $this->suratrujukanpasien->load(['ID'=>$entity['RUJUKAN']]);
					if(count($rujukan) > 0) $entity['RUJUKAN'] = $rujukan[0];
				}
				
				if($this->references['Penjamin']) {
					if(is_object($this->references['Penjamin'])) {
						$references = isset($this->references['Penjamin']->REFERENSI) ? (array) $this->references['Penjamin']->REFERENSI : [];
						$this->penjamin->setReferences($references, true);
						if(isset($this->references['Penjamin']->COLUMNS)) $this->penjamin->setColumns((array) $this->references['Penjamin']->COLUMNS);
					}
					$penjamin = $this->penjamin->load(['NOPEN'=>$entity['NOMOR'], 'NORM' => $entity['NORM']]);
					if(count($penjamin) > 0) $entity['PENJAMIN'] = $penjamin[0];
				}
				
				if($this->references['PasienPulang']) {
					$pasienPulang = $this->pasienPulang->load(['NOPEN'=>$entity['NOMOR']], ["*"], ["ID DESC"]);
					if(count($pasienPulang) > 0) $entity['REFERENSI']['PASIEN_PULANG'] = $pasienPulang[0];
				}
				
				if($this->references['PasienMeninggal']) {
					$pasienmeninggal = $this->pasienmeninggal->load(['NOPEN'=>$entity['NOMOR']]);
					if(count($pasienmeninggal) > 0) $entity['REFERENSI']['PASIENMENINGGAL'] = $pasienmeninggal[0];
				}
				
				if($this->references['Kecelakaan']) {
					$kecelakaan = $this->kecelakaan->load(['NOPEN'=>$entity['NOMOR']]);
					if(count($kecelakaan) > 0) $entity['REFERENSI']['KECELAKAAN'] = $kecelakaan[0];
				}
				if($this->references['DiagnosaUtama']) {
					$diagnosautama = $this->diagnosautama->load(['NOPEN'=>$entity['NOMOR'], 'UTAMA'=>1]);
					if(count($diagnosautama) > 0) $entity['REFERENSI']['DIAGNOSAUTAMA'] = $diagnosautama[0];
				}

				if($this->references['Referensi']) {
					$referensi = $this->referensi->load(['JENIS' => 25,'ID' => $entity['STATUS']]);
					if(count($referensi) > 0) $entity['REFERENSI']['STATUS'] = $referensi[0];
					if(isset($entity['PAKET'])) {
						$paket = $this->paket->load(['ID' => $entity['PAKET']]);
						if(count($paket) > 0) $entity['REFERENSI']['PAKET'] = $paket[0];
					}
				}

				if($this->references['PenanggungJawabPasien']) {
					$penanggung = $this->penanggungjawab->load(['NOPEN'=>$entity['NOMOR']]);
					if(count($penanggung) > 0) $entity['REFERENSI']['PENANGGUNG_PASIEN'] = $penanggung[0];					
				}

				if($this->references['Pengantar']) {
					$pengantar = $this->pengantar->load(['NOPEN'=>$entity['NOMOR']]);
					if(count($pengantar) > 0) $entity['REFERENSI']['PENGANTAR'] = $pengantar[0];					
				}

				if($this->references['Inacbg']) {
					$inacbg = $this->inacbg->load(['NOPEN' => $entity['NOMOR']]);
					if(count($inacbg) > 0) $entity['REFERENSI']['INACBG'] = $inacbg[0];
				}
				
				$entity['REFERENSI']['SYSDATE'] = System::getSysDate($this->table->getAdapter());
				
			}					
		}
		
		return $data;
	}
	
	public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;		
		$this->entity->exchangeArray($data);
		$nopen = is_numeric($this->entity->get('NOMOR')) ? $this->entity->get('NOMOR') : 0;
		$diagnosa = is_numeric($this->entity->get('DIAGNOSA_MASUK')) ? $this->entity->get('DIAGNOSA_MASUK') : 0;		
		
		$dm = $this->simpanDiagnosa($data);		
		if($dm) $this->entity->set('DIAGNOSA_MASUK', $dm);
		
		$create = false;
		if($nopen == 0) {
		    $nopen = Generator::generateNoPendaftaran();
		    $create = true;
		}
		
		$rujukan = $this->simpanRujukan($data, $dm, $nopen);
		
		if(!$create){
			$this->table->update($this->entity->getArrayCopy(), ["NOMOR" => $nopen]);
		} else {
			//$this->entity->set('TANGGAL', new \Laminas\Db\Sql\Expression('NOW()'));
			if($rujukan) $this->entity->set('RUJUKAN', $rujukan["ID"]);
			$this->entity->set('NOMOR', $nopen);
			$this->table->insert($this->entity->getArrayCopy());
		}
		
		$data['NOMOR'] = $nopen;
		
		$this->simpanTujuan($data, $nopen);
		$this->simpanPenjamin($data, $nopen);
		$this->simpanPenanggungJawab($data, $nopen);		
		$this->simpanKecelakaan($data, $nopen);
		$this->simpanPengantarPasien($data, $nopen);
		
		if($nopen > 0) {
			$results = $this->load(['NOMOR'=>$nopen]);
			if(count($results) > 0) $data = $results[0];
			return [
				'success' => true,
				'data' => $data
			];
		} else {
			return [
				'success' => false
			];
		}
	}
	
	private function simpanDiagnosa(&$data) {
		if(isset($data['DIAGNOSAMASUK'])) {
			$result = $this->diagnosa->simpan($data['DIAGNOSAMASUK']);
			
			if($result['success']) {
				return $result['data'] ? $result['data']['ID'] : null;
			}				
		}
		
		return null;
	}
	
	private function simpanTujuan(&$data, $nopen) {
		if(isset($data['TUJUAN'])) {
			$data['TUJUAN']['NOPEN'] = $nopen;
			$result = $this->tujuanpasien->simpan($data['TUJUAN']);

			/* Menjalakan function untuk create kunjungan   */ 
			if($result){
				$this->simpanKunjungan($data, $nopen);
			}
		}
	}

	private function simpanKunjungan(&$data, $nopen){
		/* jika terdapat tindakan medis pada saat create pendaftaran maka create kunjungan di jalankan */
		if(isset($data['TINDAKAN_MEDIS'])) {
			$nomor = $this->kunjungan->simpanData([
				'NOPEN' => $nopen,
				'RUANGAN' => $data['TUJUAN']['RUANGAN'],
				'DITERIMA_OLEH' => $data['OLEH'],
				'STATUS' => 1
			], true, false);
			if($nomor) {
				$result = $this->kunjungan->execute("SELECT * FROM pendaftaran.kunjungan WHERE NOMOR = ?", [$nomor]);
				if(count($result) > 0) {
					$kunjungan = $result[0];
					$tindakan = $data['TINDAKAN_MEDIS'];
					foreach($tindakan as $tm) {
						$tm['KUNJUNGAN'] = $kunjungan['NOMOR'];
						$tm['TANGGAL'] = new \Laminas\Db\Sql\Expression("DATE_ADD('".$kunjungan['MASUK']."', INTERVAL 1 SECOND)");
						$tm['OLEH'] = $data['OLEH'];
						$this->tindakanmedis->simpanData($tm, true, false);
					}
				}
			}
		}
	}

	private function simpanPenanggungJawab(&$data, $nopen) {
		if(isset($data['PENANGGUNGJAWAB'])) {
			$data['PENANGGUNGJAWAB']['NOPEN'] = $nopen;
			$exists = $this->penanggungjawab->isExists($data['PENANGGUNGJAWAB']);
			$create = true;
			if($exists) {
				$create = false;
				$data['PENANGGUNGJAWAB']['ID'] = $exists["ID"];
			}
			$this->penanggungjawab->simpanData($data['PENANGGUNGJAWAB'], $create);
		}
	}

	private function simpanPengantarPasien(&$data, $nopen) {
		if(isset($data['PENGANTAR'])) {
			$data['PENGANTAR']['NOPEN'] = $nopen;
			$exists = $this->pengantar->isExists($data['PENGANTAR']);
			$create = true;
			if($exists) {
				$create = false;
				$data['PENGANTAR']['ID'] = $exists["ID"];
			}
			$this->pengantar->simpanData($data['PENGANTAR'], $create);
		}
	}
	
	private function simpanPenjamin($data, $nopen) {
		if(isset($data['PENJAMIN'])) {
			$params = $data["PENJAMIN"];
			$params["NOPEN"] = $nopen;
			$this->penjamin->simpan($params); 
		}
	}
	
	private function simpanKAP($data) {
		if(isset($data)) {
			$params = [
				'JENIS' => $data['JENIS'],
				'NORM' => $data['NORM'],
				'NOMOR' => $data['NOMOR']
			];
			$this->kap->simpanData($params); 
		}
	}
	
	private function simpanRujukan(&$data, $dianosaMasuk, $nopen) {
		if(isset($data['SURAT_RUJUKAN'])) {
			$data['SURAT_RUJUKAN']['NORM'] = $data['NORM'];
			$data['SURAT_RUJUKAN']['NOPEN'] = $nopen;
			$data['SURAT_RUJUKAN']['DIAGNOSA_MASUK'] = $dianosaMasuk;			
			$result = $this->suratrujukanpasien->simpan($data['SURAT_RUJUKAN']);
			return count($result["data"]) > 0 ? $result["data"][0] : null;
		}
		return null;
	}
	
	private function simpanKecelakaan(&$data, $nopen) {
		if(isset($data["REFERENSI"])) {
			$ref = $data["REFERENSI"];
			if(isset($ref['KECELAKAAN'])) {
				$ref['KECELAKAAN']['NOPEN'] = $nopen;
				$this->kecelakaan->simpan($ref['KECELAKAAN'], true); 
			}
		}
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(isset($params["TANGGAL_DAFTAR"])){
			if(!System::isNull($params, 'TANGGAL_DAFTAR')){
				$select->where('TANGGAL BETWEEN "'.$params["TANGGAL_DAFTAR"].' 00:00:00" AND "'.$params["TANGGAL_DAFTAR"].' 23:59:59"');
			}
			unset($params["TANGGAL_DAFTAR"]);
		}
	}

	public function getPendaftaranAsal($kunjungan, $penjamin, $ruangan) {
        return $this->execute("SELECT pendaftaran.getPendaftaranAsal(?,?,?) AS DATA", [$kunjungan, $penjamin, $ruangan]);
    }
}