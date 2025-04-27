<?php
namespace BPJService\V1\Rpc\Kunjungan;

use DBService\RPCResource;

use Laminas\View\Model\JsonModel;
use Laminas\Json\Json;

class KunjunganController extends RPCResource
{
	private $service;
	
	public function __construct($service) 
	{
		$this->service = $service->getSEPService();
		$this->config = $this->service->getConfig();
	}

	public function getList()
    {
		$this->response->setStatusCode(405); 
		return new JsonModel([
			'data' => [
				'metadata' => [
					'message' => 'Method Not Allowed',
					'code' => 405,
					'requestId' => $this->config['koders']
				]
			]
		]);
    }
	
	public function create($data)
    {
		$data["create"] = true;
		$data["ip"] = $_SERVER["REMOTE_ADDR"];
		$data = $this->service->generateNoSEP($data);
		
		return new JsonModel([
            'data' => $data
		]);
    }
	
	public function updateSEPAction()
    {
		$data = $this->getPostData($this->getRequest());
		$data = $this->service->updateSEP($data);
		
		return new JsonModel([
            'data' => $data
		]);
    }
	
	/**
	 * @depricated
	 */
	public function mappingDataTransaksiAction()
    {
		$data = $this->getPostData($this->getRequest());
		$data = $this->service->mappingDataTransaksi($data);
		
		return new JsonModel([
            'data' => $data
		]);
    }
	
	public function updateTanggalPulangAction()
    {        
		$data = $this->getPostData($this->getRequest());
		$data = $this->service->updateTanggalPulang($data);
		
		return new JsonModel([
            'data' => $data
		]);
    }
	
	public function cekSEPAction()
    {        
		$data = $this->getPostData($this->getRequest());
		$data = $this->service->cekSEP($data["noSEP"]);
		
		return new JsonModel([
            'data' => $data
		]);
    }
	
	public function batalkanSEPAction()
    {       
		$data = $this->getPostData($this->getRequest());
		$result = $this->service->cekSEP($data["noSEP"]);
		if($result) {
			if($result->metadata->code == 200) $result = $this->service->batalkanSEP(count($data) > 1 ? $data : $data["noSEP"]);
		}
		
		return new JsonModel([
            'data' => $result
		]);
    }
	
	public function pengajuanSEPAction()
    {
		$data = $this->getPostData($this->getRequest());
		$data = $this->service->pengajuanSEP($data);
		
		return new JsonModel([
            'data' => $data
		]);
    }
	
	public function aprovalPengajuanSEPAction()
    {
		$data = $this->getPostData($this->getRequest());
		$data = $this->service->aprovalPengajuanSEP($data);
		
		return new JsonModel([
            'data' => $data
		]);
    }
	
	public function daftarPengajuanAction()
    {        		
		$params = (array) $this->getRequest()->getQuery();
		$pengajuan = $this->service->getPengajuan();
		
		$data = null;
		$count = $pengajuan->getRowCount($params);
		if($count > 0) $data = $pengajuan->load($params, ['*'], ['tgl']);
		
		return new JsonModel([
            'data' => [
				"metadata" => [
					"code" => 200,
					"message" => "Sukses"
				],
				"response" => [
					"list" => $data,
					"count" => $count
				]
			]
		]);
    }
	
	public function batalPengajuanSEPAction()
    {
		$data = $this->getPostData($this->getRequest());
		$pengajuan = $this->service->getPengajuan();
		$data = is_array($data) ? $data : (array) $data;
		if(isset($data["user"])) {
			$data["userAprove"] = $data["user"];
			$data["tglAprove"] = new \Laminas\Db\Sql\Expression('NOW()');
			unset($data["user"]);
		}
		$data["status"] = 0;
		$pengajuan->simpan($data);
		
		return new JsonModel([
            'data' => [
				"metadata" => [
					"code" => 200,
					"message" => "Sukses"
				]
			]
		]);
    }
	
	/**
	 * @depricated
	 */
	public function kunjunganPesertaAction()
    {       
		$data = $this->getPostData($this->getRequest());
		$data = $this->service->kunjunganPeserta($data["noSEP"]);
		
		return new JsonModel([
            'data' => $data
		]);
    }

	/**
	 * @depricated
	 */
	public function monitoringVerifikasiKlaimAction()
    {       
		$data = $this->getPostData($this->getRequest());
		$data = $this->service->monitoringVerifikasiKlaim($data);
		
		return new JsonModel([
            'data' => $data
		]);
    }
	
	/**
	 * @depricated
	 */
	public function riwayatPelayananPesertaAction()
    {       
		$data = $this->getPostData($this->getRequest());
		$data = $this->service->riwayatPelayananPeserta($data["noKartu"]);
		
		return new JsonModel([
            'data' => $data
		]);
    }
		
	public function inacbgAction()
    {       
		$data = $this->getPostData($this->getRequest());
		$data = $this->service->inacbg($data["noSEP"]);
		
		return new JsonModel([
            'data' => $data
		]);
    }

	public function listDataUpdateTanggalPulangAction()
    {
		$params = (array) $this->getRequest()->getQuery();
        $data = $this->service->listDataUpdateTanggalPulang($params);
        
        return new JsonModel([
            'data' => $data
        ]);
    }

	public function suplesiJasaRaharjaAction()
    {
        $params = (array) $this->getRequest()->getQuery();
        $data = $this->service->suplesiJasaRaharja($params);
        
        return new JsonModel([
            'data' => $data
        ]);
    }

	public function dataIndukKecelakaanAction()
    {       
		$id = $this->params()->fromRoute('id', 0);
		$data = $this->service->dataIndukKecelakaan($id);
		
		return new JsonModel([
            'data' => $data
        ]);
    }

	public function sepInternalAction()
    {       
		$id = $this->params()->fromRoute('id', 0);
		$data = $this->service->sepInternal($id);
		
		return new JsonModel([
            'data' => $data
        ]);
    }

	public function hapusSepInternalAction()
    {       
		$data = $this->getPostData($this->getRequest());
		$data = $this->service->hapusSepInternal($data);
		
		return new JsonModel([
            'data' => $data
		]);
    }

    public function getFingerPrintAction()
    {
        $params = (array) $this->getRequest()->getQuery();
        $data = $this->service->getFingerPrint($params);
        
        return new JsonModel([
            'data' => $data
        ]);
    }

    public function getListFingerPrintAction()
    {
        $params = (array) $this->getRequest()->getQuery();
        $data = $this->service->getListFingerPrint($params);
        
        return new JsonModel([
            'data' => $data
        ]);
    }

	// internal function
	public function getFingerAppRequestAccessAction() {
		$params = (array) $this->getRequest()->getQuery();
		if(!isset($params["jenis"])) {
			$this->response->setStatusCode(412); 
			return new JsonModel([
				'data' => [
					'metadata' => [
						'message' => 'Parameter jenis',
						'code' => 412,
						'requestId' => "Parameter jenis harus di isi"
					]
				]
			]);
		}
		if(!isset($params["nomor"])) {
			$this->response->setStatusCode(412); 
			return new JsonModel([
				'data' => [
					'metadata' => [
						'message' => 'Parameter nomor',
						'code' => 412,
						'requestId' => "Parameter nomor harus di isi"
					]
				]
			]);
		}
		if(!isset($this->config["finger"])) {
			$this->response->setStatusCode(412); 
			return new JsonModel([
				'data' => [
					'metadata' => [
						'message' => 'Konfigurasi Finger',
						'code' => 412,
						'requestId' => "Finger app belum di konfigurasikan"
					]
				]
			]);
		}
		$data = $this->service->getFingerAppRequestAccess($params);
		return new JsonModel([
            'data' => $data
		]);
	}
}
