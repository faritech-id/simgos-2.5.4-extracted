<?php
namespace ReportService;

use DBService\JavaConnection;
use DBService\Crypto;
use Laminas\Authentication\Storage\Session as StorageSession;
use Aplikasi\db\request_report\Service as RequestServiceStorage;

use DBService\System;

class ReportService extends JavaConnection
{
	/**
     * @var ReportServiceOption
     */
	private $conns = [];
		
	private $driver;
	private $driverManager;
	private $locale;
	private $localeCode;
	
	private $crypto;
	private $report;
	private $key;
	private $rss;
	private $path;
	private $pathRequest;
	private $pathContent;

	private $controller;
	private $tteConfig;
    
    public function __construct($config) {
        parent::__construct($config);
		
		$this->key = $this->config['key'];
		$this->crypto = new Crypto();

		$this->storageSession = new StorageSession("RR", "RPT");
		$this->rss = new RequestServiceStorage();

		$tgl = System::getSysDate($this->rss->getTable()->getAdapter(), false);
		$tgls = explode(" ", $tgl);
		$tgls = explode("-", $tgls[0]);
		$this->path = "reports/output/".$tgls[0]."/".$tgls[1]."/".$tgls[2]."/";
		$this->pathRequest = "reports/output/request/".$tgls[0]."/".$tgls[1]."/".$tgls[2]."/";
		$this->pathContent = "reports/output/content/".$tgls[0]."/".$tgls[1]."/".$tgls[2]."/";
		
		$this->connectionInit();
		$this->locale = new \Java("java.util.Locale", $this->config['db']['locale'][0], $this->config['db']['locale'][1]);
		$this->localeCode = $this->config['db']['locale'][0].'_'.$this->config['db']['locale'][1];
		$this->report = new Report($this->locale, $this->localeCode);
    }

	public function setController($controller) {
		$this->controller = $controller;
		$this->report->setController($controller);
	}
	
	private function connectionInit() {
		$conns = $this->config['db']['connectionStrings'];
		foreach($conns as $conn) {		
			$this->conns[] = $this->createConnection($conn);
		}		
	}
	
	private function createConnection($connString) {
		try {
			$this->driver = new \Java($this->config['db']['driver']);
			$this->driverManager = \Java($this->config['db']['driverManager']);
			$this->driverManager->registerDriver($this->driver);
			$conn = $this->driverManager->getConnection($connString);
			return $conn;
		} catch(\JavaException $e) {
			echo "</br>Error: can't connect db";
			return [
				'error' => $e->getMessage()
			];
		}
	}
	
	private function closeConnections() {
		foreach($this->conns as $conn) {
			if($conn) $conn->close();
		}
		$this->conns = [];
	}
	
	public function getReport() {
		return $this->report;
	}

	public function setTteConfig($config) {
		$this->tteConfig = $config;
	}
	
    public function generate($response, $requestReport) {
		$data = null;
		$exists = false;
		if(file_exists($this->pathRequest.$requestReport)) { // REQUEST_FOR_PRINT
			$exists = true;
			$data = file_get_contents($this->pathRequest.$requestReport);
			exec("sudo chmod 775 -Rf ".$this->pathRequest.$requestReport);
			unlink($this->pathRequest.$requestReport);
		} else {
			$data = $this->storageSession->read();
			$this->storageSession->write([]);
			if($data) $exists = true;
		}

		$dss = null;
		$dssStatus = 1;
		if(!$exists) {
			$dss = $this->rss->load([
				"KEY" => $requestReport
			]);
			if(count($dss) > 0) {
				$data = $dss[0]["REQUEST_DATA"];
				$dss = $dss[0];
				$dssStatus = $dss["STATUS"];
				if($dssStatus == 1) {
					$revs = $this->rss->load([
						"DOCUMENT_DIRECTORY_ID" => $dss["DOCUMENT_DIRECTORY_ID"],
						"REF_ID" => strval($dss["REF_ID"]),
						"start" => 0,
						"limit" => 1,
						"STATUS" => 2
					], ['*'], ['DIBUAT_TANGGAL DESC']);
					if(count($revs) > 0) $dss["REVISION_FROM"] = $revs[0]["ID"];
				}
			}
		}

		if($data) {
			$this->crypto->setKey($requestReport);			
            $data = $this->crypto->decrypt($data);
            $data = base64_decode($data);
			$data = (array) json_decode($data);

			if($dss) {
				if($dssStatus == 1) {
					if(empty($dss["TTD_OLEH"])) {
						if(isset($data["DOCUMENT_STORAGE"])) {
							if(isset($data["DOCUMENT_STORAGE"]->SIGN)) {
								if($data["DOCUMENT_STORAGE"]->SIGN == 1) {
									$rss = $this->rss->simpanData([
										"ID" => $dss["ID"],
										"TTD_OLEH" => $data["USER_ID"],
										"TTD_TANGGAL" => new \Laminas\Db\Sql\Expression("NOW()"),
										"STATUS" => 2
									], false, true);
									$dss["TTD_OLEH"] = $data["USER_ID"];
									$dss["REFERENSI"]["TTD_OLEH"] = $rss[0]["REFERENSI"]["TTD_OLEH"];
									$dss["STATUS"] = 2;
								}
							}
						}
					}
				} else {
					$dss["REQUEST_BY_ID"] = true;
				}
				$this->report->setRequestReportStorage($dss);
			}

			$data["REQUEST_ID"] = $requestReport;
			$data["TTE_CONFIG"] = $this->tteConfig;
			$id = $this->report->create(
				$response,
				$this->conns[$data["CONNECTION_NUMBER"]], 
				$data
			);

			if($id) {
				if($dss) {
					$this->rss->simpanData([
						"ID" => $dss["ID"],
						"DOCUMENT_STORAGE_ID" => $id
					], false, false);
				}
			} else {
				if($dss) {
					$this->rss->hapus([
						"ID" => $dss["ID"]
					]);
				}
			}
		}

		return $response;
	}	
}
