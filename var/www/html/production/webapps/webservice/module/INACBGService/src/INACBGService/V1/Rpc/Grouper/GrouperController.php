<?php
namespace INACBGService\V1\Rpc\Grouper;

use DBService\RPCResource;
use Laminas\View\Model\JsonModel;

use INACBGService\db\dokumen_pendukung\Service as DokumenPendukungService;
use Laminas\ApiTools\ApiProblem\ApiProblem;

class GrouperController extends RPCResource
{
	public function __construct($controllers) 
	{
		$this->authType = self::AUTH_TYPE_IP_OR_LOGIN;
		$this->service = $controllers->get('INACBGService\Service');
		$this->config = $controllers->get('Config');
		$this->config = $this->config['services'];
	}

	public function getList()
    {
		$this->response->setStatusCode(405); 
		return new JsonModel([
			'data' => [
				'metaData' => [
					'message' => 'Method Not Allowed',
					'code' => 405,
					'requestId' => $this->service->getKodeRS()
				]
			]
		]);
    }
	
	public function create($data)
    {        
		$data = (array) $this->service->grouper($data);
		
		return new JsonModel([
            'data' => $data
		]);
    }
	
	public function klaimBaruAction()
    {        
		$data = $this->getPostData();	
		$data = (array) $this->service->klaimBaru($data);
		return new JsonModel([
            'data' => $data
		]);
	}
	
	public function kirimKlaimIndividualAction()
    {        
		$data = $this->getPostData();	
		$data = (array) $this->service->kirimKlaimIndividual($data);
		return new JsonModel([
            'data' => $data
		]);
    }
	
	public function kirimKlaimAction()
    {        
		$data = $this->getPostData();	
		$data = (array) $this->service->kirimKlaim($data);
		return new JsonModel([
            'data' => $data
		]);
    }
	
	public function batalKlaimAction()
    {
		$data = $this->getPostData();
		$data = (array) $this->service->batalKlaim($data);
		return new JsonModel([
            'data' => $data
		]);
	}
	
	public function generateNomorKlaimAction()
    {
		$data = $this->getPostData();
		$data = (array) $this->service->generateNomorKlaim($data);
		return new JsonModel([
            'data' => $data
		]);
	}

	public function uploadFilePendukungAction()
    {
		$data = $this->getPostData();
		$data = (array) $this->service->uploadFilePendukung($data);
		return new JsonModel([
            'data' => $data
		]);
	}

	public function hapusFilePendukungAction()
    {
		$data = $this->getPostData();
		$data = (array) $this->service->hapusFilePendukung($data);
		return new JsonModel([
            'data' => $data
		]);
	}

	public function daftarFilePendukungAction()
    {
		$data = $this->getPostData();
		$data = (array) $this->service->daftarFilePendukung($data);
		return new JsonModel([
            'data' => $data
		]);
	}

	public function dokumenPendukungAction()
    {		
		$request = $this->getRequest();
		$params = (array) $request->getQuery();
		$data = $this->getPostData();
		$method = $request->getMethod();		        
        $id = "";
        if($method == "PUT" || $method == "GET") {
            $id = $this->params()->fromRoute('id');
			$id = $id ? $id : "";
		}
		$dps = new DokumenPendukungService();

		if($method == "GET") {			
			if($id != "") {
				$data = $dps->load([
					"id" => $id
				], ["id", "file_name", "file_type", "file_content", "document_id"]);
				if(count($data) > 0) {
					$dataDs = $data[0];
					$data = $data[0];
					if(!empty($data["file_content"]) && empty($data["document_id"])) {
						$data["file_content"] = base64_encode($data["file_content"]);
						try {
							$contentDs = "data:application/pdf;base64,".base64_encode($dataDs["file_content"]);
							$contentDs = base64_encode($contentDs);
							$dataDs["oleh_nama"] = $dataDs["REFERENSI"]["PENGGUNA"]["NAMA"];
							$this->storeToDocumentStorage($dataDs, $contentDs, null);
							$data["document_id"] = $dataDs["document_id"];
						} catch(\Exception $e) {}
						return $data;
					}
				}
			}
			$data = $dps->load([
				"no_klaim" => isset($params["no_klaim"]) ? $params["no_klaim"] : "",
				"file_class" => isset($params["file_class"]) ? $params["file_class"] : "",
				"status" => 1
			], ["id", "no_klaim", "file_id", "file_class", "file_name", "file_size", "file_type", "kirim_bpjs", "document_id"]);
			$total = count($data);
			
			return [
				"status" => $total > 0 ? 200 : 404,
				"success" => $total > 0 ? true : false,
				"total" => $total,
				"data" => $data,
				"detail" => "Data ".($total > 0 ? " ditemukan" : " tidak ditemukan")
			];
		}

		if($method == "PUT") {
			$tipe = $data["tipe"];	
			try {
				$rows = $dps->load([
					"id" => $id
				]);
			
				if(isset($data["status"])) {
					$return = [
						"status" => 422,
						"detail" => "Gagal hapus berkas"
					];	
					if($data["status"] == 0) {
						$data = $rows[0];
						if($data["kirim_bpjs"] == 1 && $data["file_type"] == "application/pdf") {
							$result = $this->service->hapusFilePendukung([
								"nomor_sep" => $data["no_klaim"],
								"file_id" => $data["file_id"],
								"tipe" => $tipe
							]);
							if($result) {
								if($result->metadata->code == 200 || $result->metadata->code == 400) {
									$dps->simpanData([
										"id" => $id,
										"status" => 0
									], false, false);
									$return["status"] = 200;
									$return["detail"] = "Berhasil hapus berkas di E-Klaim";
								} else {
									$return["status"] = $result->metadata->code;
									$return["detail"] = $result->metadata->message;
								}
							}
						} else {
							$dps->simpanData([
								"id" => $id,
								"status" => 0
							], false, false);

							$return["status"] = 200;
							$return["detail"] = "Berhasil hapus berkas di local";
						}
					}

					$this->response->setStatusCode($return["status"]);
					return new JsonModel([
						'data' => $return
					]);
				}

				$return = [
					"status" => 422,
					"detail" => "Gagal kirim berkas"
				];

				if(isset($data["kirim_bpjs"])) {
					if($data["kirim_bpjs"] == 1) {
						$data = $rows[0];
						if($data["file_type"] == "application/pdf") {
							$content = base64_encode($data["file_content"]);
							$result = $this->service->hapusFilePendukung([
								"nomor_sep" => $data["no_klaim"],
								"file_id" => $data["file_id"],
								"tipe" => $tipe
							]);
							
							// get document storage file
							if(isset($data["document_id"])) {
								if($data["document_id"] != "") {
									$file = $this->getDocumentStorage($data["document_id"]);
									if($file) $content = base64_encode($file);
								}
							}

							$result = $this->service->uploadFilePendukung([
								"nomor_sep" => $data["no_klaim"],
								"file_class" => $data["file_class"],
								"file_name" => $data["file_name"],						
								"tipe" => $tipe,
								"content" => $content
							]);
							if($result) {
								$metadata = $result->metadata;
								$response = isset($metadata->response) ? $metadata->response : $result->response;
								$bpjs = isset($metadata->upload_dc_bpjs_response) ? $metadata->upload_dc_bpjs_response : (isset($result->upload_dc_bpjs_response) ? $result->upload_dc_bpjs_response : null);
								
								$data["file_id"] = $response->file_id;
								if($bpjs) $data["kirim_bpjs"] = 0;
								else $data["kirim_bpjs"] = 1;

								$dps->simpanData([
									"id" => $id,
									"kirim_bpjs" => $data["kirim_bpjs"],
									"file_id" => $response->file_id
								], false, false);

								$return["status"] = 200;
								$return["detail"] = "Berhasil kirim berkas";
							} else {
								$return["status"] = $result->metadata->code;
								$return["detail"] = $result->metadata->message;
							}
						} else {
							$return["detail"] = $return["detail"].", berkas yang dikirim harus berupa file pdf";
						}
					}
				}
				
				$this->response->setStatusCode($return["status"]);
				return new JsonModel([
					'data' => $return
				]);
			} catch(\Exception $e) {
				$this->response->setStatusCode(422);
				return new JsonModel([
					'data' => [
						"status" => 422,
						"detail" => $e->getMessage()
					]
				]);
			}
		}

		if($method == "POST") {	
			try {
				$dataContent = null;
				if(empty($data["document_id"])) {
					$dataContent = $dps->getFileContentFromPost($data["file_content"], ['application/pdf', 'image/jpeg', 'image/png']);

					if($dataContent instanceof ApiProblem) {
						$error = $dataContent->toArray();
						$this->response->setStatusCode($errors["status"]);
						return new JsonModel([
							'data' => $error
						]);
					}
					
					if(empty($data["file_content"])) {
						$this->response->setStatusCode(422);
						return new JsonModel([
							'data' => [
								"status" => 422,
								"detail" => "File yang di upload tidak valid / parameter file_content tidak boleh kosong"
							]
						]);
					}
					$file_content = $data["file_content"];
					unset($data["file_content"]);

					$id = $dps->simpanData($data, true, false);	
					$data["id"] = $id;
					$this->storeToDocumentStorage($data, $file_content, $dataContent["content"]);
				} else {
					$id = $dps->simpanData($data, true, false);
					$file = $this->getDocumentStorage($data["document_id"]);
					if($file) {
						$dataContent = [
							"content" => $file
						];
					}
				}

				$bpjs = $result = null;
				if($dataContent) {
					$content = base64_encode($dataContent["content"]);
					if($data["tipe"] == "application/pdf") {
						$result = $this->service->uploadFilePendukung([
							"nomor_sep" => $data["no_klaim"],
							"file_class" => $data["file_class"],
							"file_name" => $data["file_name"],
							"tipe" => $data["tipe"],
							"content" => $content
						]);
						if($result) {
							$metadata = $result->metadata;
							$response = isset($metadata->response) ? $metadata->response : $result->response;
							$bpjs = isset($metadata->upload_dc_bpjs_response) ? $metadata->upload_dc_bpjs_response : (isset($result->upload_dc_bpjs_response) ? $result->upload_dc_bpjs_response : null);
							$data["file_id"] = $response->file_id;
							if($bpjs) $data["kirim_bpjs"] = 0;
							else $data["kirim_bpjs"] = 1;
							$dps->simpanData([
								"id" => $id,
								"kirim_bpjs" => $data["kirim_bpjs"],
								"file_id" => $data["file_id"]
							], false, false);
						}
					}
				}
				
				return new JsonModel([
					'data' => [
						"status" => 200,
						"detail" => "Upload file berhasil",
						"eklaim" => $result,
						"bpjs" => $bpjs					
					]
				]);
			} catch(\Exception $e) {
				$this->response->setStatusCode(422);
				return new JsonModel([
					'data' => [
						"status" => 422,
						"detail" => $e->getMessage()
					]
				]);
			}
		}
	}

	private function storeToDocumentStorage(&$data, $file_content, $dataContent) {
		$dps = new DokumenPendukungService();
		$ds = $this->config["ReportService"]["DocumentStorage"];
		$ext = "pdf";
		if($data["file_type"] == "image/jpeg") $ext = "jpg";
		if($data["file_type"] == "image/png") $ext = "png";

		$params = [
			"NAME" => "DOKUMEN PENDUKUNG - ".$data["id"],
			"EXT" => $ext,
			"DOCUMENT_DIRECTORY_ID" => 24,
			"REFERENCE_ID" => $data["id"],
			"CREATED_BY" => $data["oleh_nama"],
			"DATA" => $file_content
		];

		$result = $this->doSendRequest([
			"url" => $ds["url"],
			"action" => "document",
			"method" => "POST",
			"data" => $params
		]);

		$data["document_id"] = null;

		if($result) {
			$result = (array) $result;
			if($result["status"] == 200) $data["document_id"] = $result["data"]->ID;
			else {
				if($dataContent) {
					if($data["id"]) $dps->hapus(["id" => $data["id"]]);
				}
				unset($dps);
				throw new \Exception($result["detail"], $result["status"]);
			}			
		} else {
			if($dataContent) {
				if($data["id"]) $dps->hapus(["id" => $data["id"]]);
			}
			unset($dps);
			throw new \Exception("Gagal terhubung ke MPD", $this->httpcode);
		}
		
		//if(!isset($data["document_id"])) $data["file_content"] = $dataContent;
		if(isset($data["document_id"])) $data["file_content"] = "";
		$dps->simpanData($data, false, false);
		unset($dps);
	}

	public function getDocumentStorage($id) {
		$ds = $this->config["ReportService"]["DocumentStorage"];

		$result = $this->doSendRequest([
			"url" => $ds["url"],
			"action" => "document/requestAccess",
			"method" => "POST",
			"data" => [
				"ID" => $id
			]
		]);

		if($result) {
			$result = (array) $result;
			if($result["status"] == 200) {
				$svc = clone $this;
				$file = $svc->doSendRequest([
					"url" => $ds["url"],
					"action" => "document/download?requestAccessNumber=".$result["requestAccessNumber"],
					"json_encode_return" => false
				]);

				if($file) return $file;
			}
		}

		return false;
	}

	public function validasiNomorRegisterSITBAction()
    {
		$data = $this->getPostData();
		$data = (array) $this->service->validasiNomorRegisterSITB($data);
		return new JsonModel([
            'data' => $data
		]);
	}

	public function batalValidasiNomorRegisterSITBAction()
    {
		$data = $this->getPostData();
		$data = (array) $this->service->batalValidasiNomorRegisterSITB($data);
		return new JsonModel([
            'data' => $data
		]);
	}
}