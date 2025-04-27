<?php
namespace DBService;

class JavaConnection {
    protected $config;

    public function __construct($config) {
        $this->config = $config;
		try {
        	$this->init();
		} catch(\Exception $e) {
			return [
				'error' => $e->getMessage()
			];
		}
    }

    private function init() {
        if(!(@include_once("serial/Java.inc"))) {
			if(!file_exists("serial/Java.Inc")) {
				$curl = curl_init($this->config['javaBridge']['location']);
				curl_setopt($curl, CURLOPT_FAILONERROR, true); 
				curl_setopt($curl, CURLOPT_FOLLOWLOCATION, true);
				curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
				curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, false);
				curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
				$result = curl_exec($curl);
				file_put_contents("serial/Java.inc", $result);
			}
			
			require_once("serial/Java.inc");
		}

		return true;
    }

	public function getConfig() {
		return $this->config;
	}
}