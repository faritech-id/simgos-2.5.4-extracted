<?php

namespace BPJS\ICare;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\DatabaseService;
use DBService\System;
use DBService\RPCResource as DBRPCResource;

use \DateTime;
use \DateInterval;
use \DateTimeZone;

use Laminas\Json\Json;

use LZCompressor\LZString;

class RPCResource extends DBRPCResource
{
    protected $config;

    public function __construct($controller)
    {
        $this->authType = self::AUTH_TYPE_IP_OR_LOGIN;

        $this->config = $controller->get('Config');
        $this->config = $this->config['services']['BPJService'];
    }

    protected function onAfterAuthenticated($params = [])
    {
        if (empty($this->config["icare"])) {
            return new ApiProblem(412, "Konfigurasi API BPJS ICare belum di setting di local.php");
        }
        $this->config["url"] = $this->config["icare"]["url"];
    }

    protected function onBeforeSendRequest()
    {

        $config = isset($config) ? (count($config) > 0 ? $config : $this->config) : $this->config;
        $dt = new DateTime(null, new DateTimeZone($this->config["timezone"]));
        $dt->add(new DateInterval($config["addTime"]));
        $ts = $dt->getTimestamp();
        $var = $config["id"] . "&" . $ts;
        $sign = base64_encode(hash_hmac("sha256", utf8_encode($var), utf8_encode($config["key"]), true));
        $this->headers = [
            "Accept: application/Json; charset=utf-8",
            "X-cons-id: " . $config["id"],
            "X-timestamp: " . $ts,
            "X-signature: " . $sign,
            "user_key: " . $config["userKey"]
        ];
    }

    protected function onAfterSendRequest($curl, &$result)
    {
        if ($this->httpcode == 200 || $this->httpcode == 201) {
            $data = Json::decode($result);
            if (is_object($data)) {
                if ($data->response) {
                    $data->response = $this->decrypt($data->response);
                }
            }
            $result = Json::encode($data);
        }
    }

    protected function getTimestampRequest()
    {
        $timestamp = "";
        foreach ($this->headers as $h) {
            $head = explode(" ", $h);
            if ($head[0] == "X-timestamp:") {
                $timestamp = $head[1];
                break;
            }
        }

        return $timestamp;
    }

    protected function decrypt($string)
    {
        $encrypt_method = 'AES-256-CBC';
        $key = $this->config["id"] . $this->config["key"] . $this->getTimestampRequest();

        // hash
        $key_hash = hex2bin(hash('sha256', $key));

        // iv - encrypt method AES-256-CBC expects 16 bytes - else you will get a warning
        $iv = substr(hex2bin(hash('sha256', $key)), 0, 16);

        $output = openssl_decrypt(base64_decode($string), $encrypt_method, $key_hash, OPENSSL_RAW_DATA, $iv);
        $data = LZString::decompressFromEncodedURIComponent($output);
        return Json::decode($data);
    }

    public function getList()
    {
		$this->response->setStatusCode(405); 
		return [
            'status' => 405,
            'success' => false,
            'data' => null,
			'detail' => 'Method Not Allowed'
		];
    }

    public function get($id)
    {
		$this->response->setStatusCode(405); 
		return [
            'status' => 405,
            'success' => false,
            'data' => null,
			'detail' => 'Method Not Allowed'
		];
    }
}
