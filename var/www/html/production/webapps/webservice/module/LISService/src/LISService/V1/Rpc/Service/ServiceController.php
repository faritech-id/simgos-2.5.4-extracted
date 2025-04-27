<?php
namespace LISService\V1\Rpc\Service;

use DBService\RPCResource;
use LISService\lis\Transport;
use LISService\V1\Rest\Vendor\Service as Vendor;

class ServiceController extends RPCResource
{
	protected $authType = self::AUTH_TYPE_IP_OR_LOGIN;
	private $transport;
	protected $vendor;

	public function __construct($controller) {
		$this->config = $controller->get('Config');
		if(!empty($this->config['services']['SchedulersServiceLocation'])) $this->config = $this->config['services']['SchedulersServiceLocation'];
		if(!empty($this->config['lis'])) $this->config = $this->config['lis'];
		$this->vendor = new Vendor();
	}
	
    public function runAction()
    {
		$result = [];
		$this->transport = new Transport($this->params()->fromQuery("driverName"), $this->config);

		try {
			$orders = $this->transport->order();
			$result["Order"] = "Total Order: ".count($orders);
		} catch(\Exception $e) {
			$result["Error Order"] = $e->getMessage();
		}

		try {
			$results = $this->transport->getResult();
			$result["Result"] = "Total Result: ".count($results);
		} catch(\Exception $e) {
			$result["Error Result"] = $e->getMessage();
		}

		return $result;
    }

	public function infoAction()
    {
		if(!empty($this->config['remote'])) {
			if($this->config["remote"]) {
				$result = $this->sendRequest("info");        
				return  $this->getResultRequest($result);
			}
		}

		$result = $this->vendor->load([
			"STATUS" => 1
		]);
		foreach($result as &$r) {
			$log = shell_exec("sudo tail /var/log/cron | grep ".$r["NAMA_SCHEDULER"]);
			if($log) {
				$log = explode("\n", $log);
				if(count($log) >= 1) $log = $log[count($log) - 2];
				$log = explode(": ", $log);
				$log = $log[0];
			}
			$r["SCHEDULER_LAST_RUN"] = $log;

			// Cek koneksi db
			$messageStatus = "Connected";
			try {
				$name = $r["NAMA_SCHEDULER"] == "default_vendor" ? "winacom" : $r["NAMA_SCHEDULER"];
				$className = "\\LISService\\$name\\dbservice\\Driver";
				$obj = new $className();
				$obj->dbStatus();
			} catch(\Exception $e) {
				$messageStatus = $e->getMessage();
			}

			$r["DB_STATUS"] = $messageStatus;
		}
		
		return [
			"status" => 200,
			"data" => $result
		];
    }
}
