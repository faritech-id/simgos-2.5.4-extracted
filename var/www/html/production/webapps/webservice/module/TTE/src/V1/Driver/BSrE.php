<?php
namespace TTE\V1\Driver;

use Laminas\Authentication\Storage\Session as StorageSession;
use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\DatabaseService;
use DBService\System;
use DBService\RPCResource as DBRPCResource;

use Endroid\QrCode\Builder\Builder;
use Endroid\QrCode\Encoding\Encoding;
use Endroid\QrCode\ErrorCorrectionLevel\ErrorCorrectionLevelHigh;
use Endroid\QrCode\RoundBlockSizeMode\RoundBlockSizeModeMargin;
use Endroid\QrCode\Writer\PngWriter;

use Aplikasi\V1\Rest\Instansi\InstansiService;
use TTE\V1\Db\sign\Service;

class BSrE extends DBRPCResource
{
    protected $jenisBridge = 7;
	private $controller;
    
    public function __construct($controller) {
		$this->controller = $controller;
        $this->config = $controller->getConfig();
        $this->config = $this->config['services']['tte'];

		$this->service = new Service();
    }

    protected function onBeforeSendRequest() {
        $auth = base64_encode(base64_decode($this->config['username']).':'.base64_decode($this->config['password']));
        $this->headers = [
            "cache-control: no-cache",
            "Authorization: Basic ".$auth
        ];
    }

    /*
     * Overwrite mothod doSendRequest
	 * array(
	 *		url => "Uniform Resource Locator",
	 *		action => "Web Service Name",
	 *		method => "{GET|POST|PUT|DELETE}",
	 *		data => "JSON String",
	 *		headers => [],
	 *      files => [],
	 * )
	*/
	public function doSendRequest($options = []) {
		$curl = curl_init();

        $rHeaders = [];
		
		$action = isset($options["action"]) ? (trim($options["action"]) != "" ? "/".$options["action"] : "") : "";				
		
		// default false
		$data = "";
		if(isset($options["data"])) $data = $options["data"];
		
		$this->onBeforeSendRequest();

		$headers = $this->headers;
		if(isset($options["headers"])) $headers = array_merge($headers, $options["headers"]);

        /* Di komen krn terlalu besar data yg akan disimpan di log
		$id = $this->writeBridgeLog([
			"URL" => $options["url"].$action,
			"HEADERS" => json_encode($headers),
			"REQUEST" => $data,
			"ACCESS_FROM_IP" => $_SERVER['REMOTE_ADDR']
		]);
        */
		
		curl_setopt($curl, CURLOPT_URL, $options["url"].$action);
		curl_setopt($curl, CURLOPT_HEADER, false);
		curl_setopt($curl, CURLOPT_CUSTOMREQUEST, isset($options["method"]) ? $options["method"] : "GET");
		curl_setopt($curl, CURLOPT_POSTFIELDS, $data);	
		
		curl_setopt($curl, CURLOPT_FOLLOWLOCATION, true); 
		curl_setopt($curl, CURLOPT_RETURNTRANSFER, true); 
		curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, false); 
		curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
		curl_setopt($curl, CURLOPT_HTTPHEADER, $headers);
        curl_setopt($curl, CURLOPT_MAXREDIRS, 10);
        curl_setopt($curl, CURLOPT_ENCODING, "");
        curl_setopt($curl, CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_1_1);
        curl_setopt($curl, CURLOPT_HEADERFUNCTION, function($curl, $head) use (&$rHeaders)
        {
          $len = strlen($head);
          $head = explode(':', $head, 2);
          if (count($head) < 2) // ignore invalid headers
            return $len;
      
          $rHeaders[strtolower(trim($head[0]))] = trim($head[1]);
      
          return $len;
        });
		$timeout = isset($options["timeout"]) ? $options["timeout"] : 30;
		curl_setopt($curl, CURLOPT_CONNECTTIMEOUT, $timeout);
		curl_setopt($curl, CURLOPT_TIMEOUT, $timeout);		
		
		$response = curl_exec($curl);
		$err = curl_error($curl);

		$this->httpcode = curl_getinfo($curl, CURLINFO_HTTP_CODE);
        $this->responseHeaders = $rHeaders;
		$this->onAfterSendRequest($curl, $response);	
		curl_close($curl);

		if($err) $this->error = $err;
		
        /* Di komen krn terlalu besar data yg akan disimpan di log
		$this->writeBridgeLog([
			"ID" => $id,
			"RESPONSE" => $result
		]);
        */
		return $response;
	}

	public function createPostFile($fileLocation) {
		$fl = pathinfo($fileLocation);
		if($fl) {
			$mime = mime_content_type($fileLocation);
			$name = $fl["basename"];
			return curl_file_create($fileLocation, $mime, $name);
		}
		return null;
	}

	public function sign($data) {
		$return = [
			"status" => 422,
			"success" => false,
			"detail" => "Gagal tanda tangan elektronik"
        ];

		if(empty($data["nik"])) throw new \Exception("Parameter nik tidak boleh kosong", 412);
        if(empty($data["passphrase"])) throw new \Exception("Parameter passphrase tidak boleh kosong", 412);
		if(empty($data["refId"])) throw new \Exception("Parameter refId tidak boleh kosong", 412);
		if(empty($data["refJenis"])) throw new \Exception("Parameter refJenis tidak boleh kosong", 412);

		$file = null;
		if(isset($_FILES["file"])) $file = $this->createPostFile($_FILES["file"]["tmp_name"]);
		if(isset($data["file_location"])) $file = $this->createPostFile($data["file_location"]);
		if($file == null) throw new \Exception("Parameter file atau file_location tidak boleh kosong", 412);
            
		$params = [
			"nik" => $data["nik"],
			"passphrase" => $data["passphrase"],
			"file" => $file
		];
		
		$config = $this->getConfig();
		$params = array_merge($params, $config["params"]);
		$imageLocation = "";
		if($params["image"]) {
			$url = isset($data["url"]) ? $data["url"] : "";
			$content = $url.(System::toUUIDEncode($data["refId"]));
			$imageLocation = $this->createQRCode($data["refId"], $content, $params);
			$params["imageTTD"] = $this->createPostFile($imageLocation);
		}
		$results = $this->doSendRequest([
			"url" => $config["url"],
			"action" => "sign/pdf",
			"method" => "POST",
			"headers" => [
				"Content-type: multipart/form-data"
			],
			"data" => $params
		]);
		
		if(isset($_FILES["file"])) unlink($_FILES["file"]["tmp_name"]);
		if($imageLocation != "") unlink($imageLocation); 
		$contentType = "";
		if($this->responseHeaders) {
			$ctypes = explode(";", $this->responseHeaders["content-type"]);
			$contentType = $ctypes[0];
		}
		if($this->httpcode == 200 || $this->httpcode == 201) {
			if($contentType == 'application/json') {
				$res = json_decode($results);
				$return["status"] = $res->status;
				$return["success"] = $res->success;
				$return["detail"] = $res->detail;
				return $return;
			}
			if(!empty($id = $this->responseHeaders["id_dokumen"])) {
				$this->service->simpanData([
					"PROVIDER_ID" => 1,
					"PROVIDER_REF_ID" => $id,
					"REF_ID" => $data["refId"],
					"REF_JENIS" => $data["refJenis"],
					"TTD_OLEH" => $data["nik"],
					"TTD_TANGGAL" => new \Laminas\Db\Sql\Expression("NOW()")
				], true, false);
				if(!isset($data["file_location"])) {
					$filename = $id."_sign.pdf";
					$response = $this->controller->getResponse();
					$response->setContent($results);
					$headers = $response->getHeaders();
					$headers->addHeaderLine('Content-Type', "application/pdf")
					->addHeaderLine('Content-Length', strlen($results))
					->addHeaderLine('dokumen-id', $id)
					->addHeaderLine('Content-Disposition', 'attachment; filename="'.$filename.'"');
					return $response;
				}
				$fl = pathinfo($data["file_location"]);
				$filename = $fl["dirname"]."/".$data["refId"]."_sign.pdf";
				file_put_contents($filename, $results);
				$return["status"] = 200;
				$return["success"] = true;
				$return["detail"] = "Berhasil tanda tangan elektronik";
				return $return;
			}
		} else {
			if($contentType == 'application/json') {
				$res = json_decode($results);
				$path = !empty($res->path) ? " -> ".$res->path : "";
				throw new \Exception($res->error.$path, $res->status);
			}
			throw new \Exception($results, $this->httpcode);
		}

		throw new \Exception($return["detail"], $return["status"]);
        /*
        if(isset($data["file_location"])) {
            if(file_exists($data["file_location"])) {
                $result["file"] = $this->createPostFile($data["file_location"]);
                $info = pathinfo($data["file_location"]);
                $content = file_get_contents($data["file_location"]);
                file_put_contents("logs/".$info["basename"], $content);
                //unlink($data["file_location"]);
            }
        }
        */
	}

	public function createQRCode($id, $content, &$params = []) {
		$is = new InstansiService();
		$instansi = $is->load()[0];
		$file = "";
		$logo = [
			"width" => 50,
			"height" => 50
		];
		if(isset($params["logo"])) {
			$logo = array_merge($logo, $params["logo"]);
			unset($params["logo"]);
		}
		$qrcode = Builder::create()
			->writer(new PngWriter())
			->writerOptions([])
			->data($content)
			->encoding(new Encoding('UTF-8'))
			->errorCorrectionLevel(new ErrorCorrectionLevelHigh())
			->size($params["width"])
			->margin(10)
			->roundBlockSizeMode(new RoundBlockSizeModeMargin())
			->logoPath(realpath('.').'/reports/images/'.$instansi["ID"].'.png')
			->logoResizeToWidth($logo["width"])
			->logoResizeToHeight($logo["height"])
			->validateResult(false)
			->build();

		$path = "reports/output/images_tmp";
		exec("sudo mkdir -p ".$path);
		exec("sudo chmod 777 -Rf ".$path);
		$file = $path."/".$id.".png";
		file_put_contents($file, $qrcode->getString());

		unset($instansi);
		unset($qrcode);
		
		return $file;
	}
}