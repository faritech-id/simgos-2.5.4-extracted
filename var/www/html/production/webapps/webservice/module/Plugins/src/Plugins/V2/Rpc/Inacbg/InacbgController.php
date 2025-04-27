<?php
namespace Plugins\V2\Rpc\Inacbg;

use DBService\RPCResource;
use Laminas\Json\Json;
use Laminas\ApiTools\ApiProblem\ApiProblem;

class InacbgController extends RPCResource
{
	protected $authType = self::AUTH_TYPE_LOGIN;
	
	public function __construct($controller) {
		$this->jenisBridge = 2;
	    $this->config = $controller->get('Config');
		$this->config = $this->config['services']['SIMpelService'];
		$this->config = $this->config['plugins']['INACBG'];
	}
	
    private function validateRequest($result) {
		try {
			$result = (array) Json::decode($result);			
			$data = isset($result['data']) ? $result['data'] : null;
			$api = null;
			if($data) {				
				if(isset($data->metaData)) {
					if($data->metaData->code != 200) {
						$api = new ApiProblem(412, $data->metaData->message.'('.$data->metaData->code.')');
						$meta = $data->metaData;
						$data = $api->toArray();
						$data["metadata"] = (array) $meta;
					}
				} else if(isset($data->metadata)) {
				    if($data->metadata->code != 200) {
				        $api = new ApiProblem(412, $data->metadata->message.'('.$data->metadata->code.')');
				        $meta = $data->metadata;
						$data = $api->toArray();
						$data["metadata"] = (array) $meta;
				    }
				} else {
				    if(isset($data->status)) {
    				    if($data->status != 0){
							if(isset($data->cbg_code)) {
								$api = new ApiProblem(412, $data->cbg_code.'-'.$data->status);
								$data = $api->toArray();
							} else {
								$api = new ApiProblem($data->status, $data->detail);
								$data = $api->toArray();
							}
    				    }
				    }
				}
			} else { // if data is null
				$error = [
					"status" => 503,
					"detail" => "Data is null"
				];

				if($result) {
					if(isset($result["status"])) {
						$error["status"] = $result["status"];
						$error["detail"] = $result["detail"];
					}
				}

				if($error["status"] != 200) {
					$api = new ApiProblem($error["status"], $error["detail"]);
					$data = $api->toArray();
				}
			}
			
			if($api) $this->response->setStatusCode($api->__get('status'));
		} catch(\Exception $e) {
			$api = new ApiProblem(500, $result);
			$data = $api->toArray();
			$this->response->setStatusCode($api->__get('status'));
		}		
		return $api ? $data : (array) $data;
	}
	
    public function getList()
    {
		return $this->validateRequest($this->sendRequest('grouper'));
    }
	
	/* Grouper */
	public function create($data)
    {        
		$data = (array) $this->validateRequest($this->sendRequest('grouper', 'POST', Json::encode($data)));		
		if(isset($data['status'])) return $data;
		return [
			'success' => true,
			'data' => $data
		];
	}
	
	/* Klaim Baru */
	public function klaimBaruAction()
    {       
		$data = $this->getPostData();
		$data = (array) $this->validateRequest($this->sendRequest('grouper/klaimBaru', 'POST', Json::encode($data)));		
		
		if(isset($data['status'])) return $data;		
		return [
			'success' => true,
			'data' => $data
		];
    }
	
	/* kirimKlaimIndividual */
	public function kirimKlaimIndividualAction()
    {       
		$data = $this->getPostData();
		$data = (array) $this->validateRequest($this->sendRequest('grouper/kirimKlaimIndividual', 'POST', Json::encode($data)));		
		
		if(isset($data['status'])) return $data;		
		return [
			'success' => true,
			'data' => $data
		];
    }
	
	/* kirimKlaimIndividual */
	public function kirimKlaimAction()
    {       
		$data = $this->getPostData();
		$data = (array) $this->validateRequest($this->sendRequest('grouper/kirimKlaim', 'POST', Json::encode($data)));		
		
		if(isset($data['status'])) return $data;		
		return [
			'success' => true,
			'data' => $data
		];
    }
	
	/* batalKlaim */
	public function batalKlaimAction()
    {       
		$data = $this->getPostData();
		$data = (array) $this->validateRequest($this->sendRequest('grouper/batalKlaim', 'POST', Json::encode($data)));		
		
		if(isset($data['status'])) return $data;		
		return [
			'success' => true,
			'data' => $data
		];
	}
	
	/* icd ina grouper */
	public function icdInaGrouperAction()
    {
		$params = (array) $this->getRequest()->getQuery();		
		$query = count($params) > 0 ? "?".http_build_query($params) : "";
		$data = (array) $this->validateRequest($this->sendRequest('icdina-grouper'.$query));
		
		if(isset($data['status'])) return $data;		
		return [
			'success' => true,
			'data' => $data
		];
	}

	/* generateNomorKlaim */
	public function generateNomorKlaimAction()
    {       
		$data = $this->getPostData();
		$data = (array) $this->validateRequest($this->sendRequest('grouper/generateNomorKlaim', 'POST', Json::encode($data)));
		
		if(isset($data['status'])) return $data;		
		return [
			'success' => true,
			'data' => $data
		];
	}
	
	/* uploadFilePendukung */
	public function uploadFilePendukungAction()
    {       
		$data = $this->getPostData();
		$data = (array) $this->validateRequest($this->sendRequest('grouper/uploadFilePendukung', 'POST', Json::encode($data)));		
		
		if(isset($data['status'])) return $data;		
		return [
			'success' => true,
			'data' => $data
		];
	}
	
	/* hapusFilePendukung */
	public function hapusFilePendukungAction()
    {       
		$data = $this->getPostData();
		$data = (array) $this->validateRequest($this->sendRequest('grouper/hapusFilePendukung', 'POST', Json::encode($data)));		
		
		if(isset($data['status'])) return $data;		
		return [
			'success' => true,
			'data' => $data
		];
	}
	
	/* daftarFilePendukung */
	public function daftarFilePendukungAction()
    {       
		$data = $this->getPostData();
		$data = (array) $this->validateRequest($this->sendRequest('grouper/daftarFilePendukung', 'POST', Json::encode($data)));		
		
		if(isset($data['status'])) return $data;		
		return [
			'success' => true,
			'data' => $data
		];
	}
	
	/* E-Klaim - Dokumen Pendukung
     * @method dataPendukung
     * @post @put array(
     *    "id" => int
	 *    , "no_klaim" => string
     *    , "file_id" => int
     *    , "file_class" => string
     *    , "file_name" => string
	 *    , "file_size" => float
	 *    , "file_type" => string
	 *    , "file_content" => string (base64_encode)
	 *    , "kirim bpjs" => int // 1 jika berhasil kirim ke bpjs
	 *    , "document_id" => upload ke dokumen storage
	 *    , "tanggal" => tanggal upload
	 *    , "oleh" => pengguna id
	 *    , "status" => int // 1 aktif; 2 no aktif di e-klaim di hapus
     * )
     * @return array | mixed
     */
    public function dokumenPendukungAction()
    {       
        $query = (array) $this->getRequest()->getQuery();
        $query = count($query) > 0 ? "?".http_build_query($query) : "";
		$request = $this->getRequest();
        $method = $request->getMethod();
        $id = "";
		$oleh = $this->user;
        if($method == "PUT" || $method == "GET") {
            $id = $this->params()->fromRoute('id');
			$id = $id ? "/".$id : "";
			$oleh = null;
		}
        if($method != "GET") $query = "";
		$data = $this->getPostData($request);
		$data = is_array($data) ? $data : (array) $data;
		if(!empty($oleh)) {
			$data["oleh"] = $oleh;
			$data["oleh_nama"] = $this->dataAkses->NAME;
		}
		$data = Json::encode($data);
		try {
			$result = $this->sendRequest('grouper/dokumenPendukung'.$id.$query, ($method != "GET" ? $method : "GET"), $data);	
			$data = Json::decode($result, Json::TYPE_ARRAY);	

			if($data) {
				if(isset($data["data"])) {
					if(isset($data["data"]["status"])) {
						if(!($data["data"]["status"] == 200 || $data["data"]["status"] == 201) && $method != "GET") {
							$this->response->setStatusCode($data["data"]["status"]);
							return $data["data"];
						}
					}
				}
			}
			if($method == "GET" && is_numeric(str_replace("/", "", $id))) {			
				$data["file_content"] = base64_decode($data["file_content"]);
				$fs = explode(".", $data["file_name"]);	
				return $this->downloadDocument($data["file_content"], $data["file_type"], $fs[1], $fs[0], false);			
			} 
		} catch(\Exception $e) {
			$data = (new ApiProblem(500, $result))->toArray();
			$this->response->setStatusCode(500);
		}
		return $data;
    }
	
	/* Validasi Nomor Register SITB */
	public function validasiNomorRegisterSITBAction()
    {       
		$data = $this->getPostData();
		$data = (array) $this->validateRequest($this->sendRequest('grouper/validasiNomorRegisterSITB', 'POST', Json::encode($data)));		
		
		if(isset($data['status'])) return $data;		
		return [
			'success' => true,
			'data' => $data
		];
    }

	/* Membatalkan Validasi Nomor Register SITB */
	public function batalValidasiNomorRegisterSITBAction()
    {
		$data = $this->getPostData();
		$data = (array) $this->validateRequest($this->sendRequest('grouper/batalValidasiNomorRegisterSITB', 'POST', Json::encode($data)));		
		
		if(isset($data['status'])) return $data;
		return [
			'success' => true,
			'data' => $data
		];
    }
}
