<?php
namespace Plugins\V2\Rpc\Bpjs;

use DBService\RPCResource;
use Laminas\Json\Json;
use Laminas\ApiTools\ApiProblem\ApiProblem;

class BpjsController extends RPCResource
{
	protected $authType = self::AUTH_TYPE_LOGIN;

	private $peserta;
	private $sep;
	private $rujukan;
	private $referensi;
	private $monitoring;
	private $aplicares;
	private $rk;
	private $prb;	

	public function __construct($controller) {
	    $this->config = $controller->get('Config');
		$this->config = $this->config['services']['SIMpelService'];
		$this->config = $this->config['plugins']['BPJS'];

		$this->jenisBridge = 1;

		$this->peserta = new Peserta($this);
		$this->sep = new SEP($this);
		$this->rujukan = new Rujukan($this);
		$this->referensi = new Referensi($this);
		$this->monitoring = new Monitoring($this);
		$this->aplicares = new Aplicares($this);
		$this->rk = new RencanaKontrol($this);
		$this->prb = new PRB($this);
	}
	
	public function validateRequest($result) {
		try {			
			$result = (array) Json::decode($result);	
			$data = isset($result['data']) ? $result['data'] : null;
			$api = null;
			if($data) {
				if(isset($data->metadata)) {
					if($data->metadata->code == 200) {	
						$data = (array) $data->response;
					} else {
						$api = new ApiProblem(412, $data->metadata->message.'('.$data->metadata->code.')');
						$data = $api->toArray();
					}
				} else {
					$api = new ApiProblem(503, 'Metadata is null');
					$data = $api->toArray();
				}
			} else { // if data is null
				$api = new ApiProblem(503, 'Data is null');
				$data = $api->toArray();
			}
			
			if($api) $this->response->setStatusCode($api->__get('status'));
		} catch(\Exception $e) {
			$api = new ApiProblem(500, $result);
			$data = $api->toArray();
			$this->response->setStatusCode($api->__get('status'));
		}
		
		return $data;
	}
	
	public function getPostData() {
		return parent::getPostData();
	}
	
    public function getList()
    {
		return $this->validateRequest($this->sendRequest('peserta'));
    }
	
	public function versionAction() 
	{
		return [
			"version" => 2
		];
	}

	/* Kepesertaan */
	/* cari peserta */
	public function get($id) 
	{
		return $this->peserta->get($id);
	}		
	public function nikAction() 
	{
		return $this->peserta->nik();
    }
	
	/* Kunjungan */
	/* buat SEP */
	public function create($data)
    {
		return $this->sep->create($data);
    }
	public function updateSEPAction()
    {
		return $this->sep->update();
    }
	/** @depricated */
	public function mappingDataTransaksiAction()
    {
		return $this->sep->mappingDataTransaksi();
    }
	public function updateTanggalPulangAction()
    {
		return $this->sep->updateTanggalPulang();
    }
	public function cekSEPAction()
    { 
		return $this->sep->cek();
    }
	public function batalkanSEPAction()
    {
		return $this->sep->batalkan();
    }
	public function pengajuanSEPAction()
    {
		return $this->sep->pengajuan();
    }
	public function aprovalPengajuanSEPAction()
    {
		return $this->sep->aprovalPengajuan();
    }
	public function daftarPengajuanAction()
    {
		return $this->sep->daftarPengajuan();
    }
	public function batalPengajuanSEPAction()
    {
		return $this->sep->batalPengajuan();
    }
	/** @depricated */
	public function kunjunganPesertaAction()
    {
		return $this->sep->kunjunganPeserta();
    }
	/** @depricated */
	public function monitoringVerifikasiKlaimAction()
    {
		return $this->sep->monitoringVerifikasiKlaim();
    }
	/** @depricated */
	public function riwayatPelayananPesertaAction()
    {
		return $this->sep->riwayatPelayananPeserta();
    }
	public function inacbgAction()
    {
		return $this->sep->inacbg();
    }
	public function suplesiJasaRaharjaAction() {
		return $this->sep->suplesiJasaRaharja();
    }
	public function dataIndukKecelakaanAction()
	{
		return $this->sep->dataIndukKecelakaan();
    }
	public function listDataUpdateTanggalPulangAction()
    {
		return $this->sep->listDataUpdateTanggalPulang();
    }
	public function sepInternalAction()
	{
		return $this->sep->sepInternal();						
    }
	public function hapusSepInternalAction()
    {
		return $this->sep->hapusSepInternal();
    }
	public function getFingerPrintAction()
    {
		return $this->sep->getFingerPrint();
    }
	public function getListFingerPrintAction()
    {
		return $this->sep->getListFingerPrint();
    }
	public function getFingerAppRequestAccessAction()
    {
		return $this->sep->getFingerAppRequestAccess();
    }
	
	/* Rujukan */
	public function cariRujukanDgnNoRujukanAction() 
	{
		return $this->rujukan->cariRujukanDgnNoRujukan();
    }
	public function cariRujukanDgnNoKartuBPJSAction() 
	{
		return $this->rujukan->cariRujukanDgnNoKartuBPJS();
    }
    public function listRujukanAction() {
		return $this->rujukan->list();
    }
	public function insertRujukanAction() 
	{
		return $this->rujukan->insert();
    }
	public function updateRujukanAction() 
	{
		return $this->rujukan->update();
    }
	public function deleteRujukanAction() 
	{
		return $this->rujukan->delete();
    }
	public function simpanRujukanAction() 
	{
		return $this->rujukan->simpan();
    }
	public function listSpesialistikRujukanAction() {
		return $this->rujukan->listSpesialistik();
    }
	public function listSaranaRujukanAction() {
		return $this->rujukan->listSarana();
    }
	public function insertRujukanKhususAction() {
		return $this->rujukan->insertRujukanKhusus();
    }
	public function deleteRujukanKhususAction() {
		return $this->rujukan->deleteRujukanKhusus();
    }
	public function listRujukanKhususAction() {
		return $this->rujukan->listRujukanKhusus();
    }
	
	/* Referensi */
	public function referensiAction() {
		return $this->referensi->list();
	}
	public function poliAction() {
		return $this->referensi->poli();
	}
	public function diagnosaAction() {
		return $this->referensi->diagnosa();
	}
	public function procedureAction() {
		return $this->referensi->procedure();
	}
	public function kelasRawatAction() {
		return $this->referensi->kelasRawat();
	}
	public function dokterAction() {
		return $this->referensi->dokter();
	}
	public function spesialistikAction() {
		return $this->referensi->spesialistik();
	}
	public function ruangRawatAction() {
		return $this->referensi->ruangRawat();
	}
	public function caraKeluarAction() {
		return $this->referensi->caraKeluar();
	}
	public function pascaPulangAction() {
		return $this->referensi->pascaPulang();
	}
	public function faskesAction() {
		return $this->referensi->faskes();
	}
	public function dpjpAction() {
		return $this->referensi->dpjp();
	}
	public function propinsiAction() {
		return $this->referensi->propinsi();
	}
	public function kabupatenAction() {
		return $this->referensi->kabupaten();
	}
	public function kecamatanAction() {
		return $this->referensi->kecamatan();
	}
	public function wilayahAction() {
		return $this->referensi->wilayah();
	}
	public function diagnosaPrbAction() {
        return $this->referensi->diagnosaPrb();
    }
	public function obatGenerikPrbAction() {
        return $this->referensi->obatGenerikPrb();
    }
	
	/* Monitoring */
	public function monitoringKunjunganAction()
    {     
		return $this->monitoring->kunjungan();
    }
	public function monitoringKlaimAction()
    {     
		return $this->monitoring->klaim();
    }
    public function monitoringHistoriPelayananAction() {
		return $this->monitoring->historiPelayanan();
    }
    public function monitoringKlaimJaminanJasaRaharjaAction() {
        return $this->monitoring->klaimJaminanJasaRaharja();
	}

	/* Aplicares */
	public function aplicaresReferensiKamarAction() {
		return $this->aplicares->referensiKamar();
	}
	public function aplicaresKetersediaanKamarRSAction() {
		return $this->aplicares->ketersediaanKamarRS();
	}
	public function aplicaresTempatTidurAction() {
		return $this->aplicares->tempatTidur();
	}
	public function aplicaresHapusTempatTidurAction()
    {       
		return $this->aplicares->hapusTempatTidur();
	}
	public function aplicaresMapKelasAction()
    {       
		return $this->aplicares->mapKelas();
    }

	/* Rencana Kontrol */
	public function rencanaKontrolAction() 
	{				
		return $this->rk->rencanaKontrol();
    }
	public function rencanaKontrolSepAction() 
	{				
		return $this->rk->sep();
    }	    
    public function rencanaKontrolDataPoliAction() {
        return $this->rk->dataPoli();
    }
	public function rencanaKontrolDataDokterAction() {
        return $this->rk->dataDokter();
    }

	/* Pembuatan Rujuk Balik (PRB) */
	public function cariSRBBerdasarkanNomorAction() {
		return $this->prb->cariSRBBerdasarkanNomor();
	}
	public function cariSRBBerdasarkanTanggalAction() {		
		return $this->prb->cariSRBBerdasarkanTanggal();
	}	
}