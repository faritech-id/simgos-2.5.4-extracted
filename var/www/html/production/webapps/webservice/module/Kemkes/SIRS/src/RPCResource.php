<?php
namespace Kemkes\SIRS;

use Laminas\Authentication\Storage\Session as StorageSession;
use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\DatabaseService;
use DBService\System;
use DBService\RPCResource as DBRPCResource;

class RPCResource extends DBRPCResource
{
    protected $jenisBridge = 3;
    protected $config;
    protected $token;
    protected $storageSession;
    
    public function __construct($controller) {
        $this->authType = self::AUTH_TYPE_IP_OR_LOGIN;

            $this->config = $controller->get('Config');
            $this->config = $this->config['services']['KemkesService'];
    }

    protected function onAfterAuthenticated($params = []) {
        if(empty($this->config['SIRS'])) {
            return new ApiProblem(412, "Konfigurasi API Kemkes SIRS belum di setting di local.php");
        }
        $this->config = $this->config['SIRS'];
        $this->storageSession = new StorageSession("OAUTH", "TOKEN");

        $this->token = $this->getToken();
    }

    protected function onBeforeSendRequest() {
        if($this->token) {
            $this->headers = [
                'Accept: */*',
                'Content-type: application/json',
                "Authorization: Bearer ".$this->token
            ];
        };
    }

    protected function getToken() {
        $db = DatabaseService::get("SIMpel");
		$adapter = $db->getAdapter();
        $session = $this->storageSession->read();
        $expired = true;
        $sysdate = System::getSysDate($adapter);
        $waktu = explode(" ", $sysdate)[1];

        if($session) {
            $data = (array) $session;
            if(!empty($data["access_token"])) {
                $expiresIn = "hh:mm:ss";
                if(strpos($data["expires_in"], "m")) { // menit
                    $m = str_pad(str_replace("m", "", $data["expires_in"]), 2, "0", STR_PAD_LEFT);
                    $expiresIn = "00:".$m.":00";
                }

                if($expiresIn != "hh:mm:ss") {
                    $currentTime = System::getDiffTime($adapter, $data["waktu"], $waktu);
                    if($currentTime > '00:00:00' && $currentTime < $expiresIn) return $data["access_token"];
                }
            }
        }

        $result = $this->doSendRequest([
            "url" => $this->config['url'],
            "action" => "login",
            "method" => "POST",
            "header" => [
                'Content-type: application/json'
            ],
            "data" => [
                "email" => $this->config["email"],
                "password" => $this->config["pass"],
            ]
        ]);

        if($this->httpcode == 201) {
            if($result->status) {
                $data = (array) $result->data;
                $data["waktu"] = $waktu;
                $this->storageSession->write(json_decode(json_encode($data)));
                return $result->data->access_token;
            }
        }

        return false;
    }
}