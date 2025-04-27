<?php
namespace Kemkes\RSOnline;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource AS DBResource;
use Aplikasi\Signature;

class Resource extends DBResource
{
    public function __construct() {
        parent::__construct();
        $this->authType = self::AUTH_TYPE_IP_OR_LOGIN;
        $this->jenisBridge = 3;
    }

    public function setServiceManager($serviceManager) {
        parent::setServiceManager($serviceManager);
        $this->config = $this->serviceManager->get('Config');
        $this->config = $this->config['services']['KemkesService'];        
        $this->config = $this->config['RsOnline'];
	}

    protected function onBeforeSendRequest() {
        $this->headers = [
            "Accept: application/json",
            "X-rs-id: ".$this->config["id"],
            "X-pass: ".$this->config["key"]
        ];
        $sign = new Signature(null, null, null);
        $timestamp = $sign->getTimestamp();  
        $this->headers[] = "X-Timestamp: ".$timestamp;
    }
}
