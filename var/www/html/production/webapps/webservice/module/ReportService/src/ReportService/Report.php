<?php
namespace ReportService;

use ReportService\Html;
use ReportService\Pdf;
use ReportService\Word;
use ReportService\Excel;

use DBService\System;

class Report
{	
	/* report vars */
	private $jasperLoader;
	private $jasperReport;
	private $jrParameter;
	private $params;
	private $file;
	private $fillManager;
	private $jasperPrint;
	
	private $jrxmloader;
	private $jrDesign;
	private $jcm;

	private $locale;
	private $localeCode;

	private $controller;
	private $requestReportStorage = null;
    
    public function __construct($locale, $localeCode) {		
		$this->reportInit();
		$this->path = $this->getReportRoot();		
		$this->locale = $locale;
		$this->localeCode = $localeCode;
    }

	public function setController($controller) {
		$this->controller = $controller;
	}

	public function setRequestReportStorage($rrs) {
		$this->requestReportStorage = $rrs;
	}

	public function create($response, $conn, $config) {
		$rptname = $config["NAME"];
		$rpttype = $config["TYPE"];
		$rptext = $config["EXT"];
		$rptparams = $config["PARAMETER"];
		$rptFileName = empty($config["FILENAME"]) ? "" : $config["FILENAME"];
		$requestPrint = $config["REQUEST_FOR_PRINT"];
		$dsc = (array) $config["DOCUMENT_STORAGE"];
		$fileInfo = $this->getInfofileReport();
		if($this->requestReportStorage) $this->requestReportStorage["NAMA_USER"] = $config["USER_NAMA"];
				
		if(!$fileInfo["exists"]) {
			$fname = $this->path."/".$this->replace($rptname, ".", "/").".jrxml";
			if(!file_exists($fname)) {
				$pos = strpos($rptname, "plugins.");
				if($pos == 0 && !is_bool($pos)) {
					$tname = $this->replace($rptname, "plugins.", "");
					$tnames = explode(".", $tname);
					$rname = $tnames[count($tnames) - 1];
					$tname = $this->replace($tname, ".".$rname, "");
					$pname = $this->replace($tname, ".", "-");
					$tname = $this->replace($tname, ".", "/");
					$path = $this->replace($this->path, "/webservice/reports", "");
					if(file_exists($path."/plugins/".$pname."/reports/".$tname."/".$rname.".jrxml")) $fname = $path."/plugins/".$pname."/reports/".$tname."/".$rname.".jrxml";
				}
			}

			/*try {
				$this->file = new \Java("java.io.File", $path."/".$this->replace($rptname, ".", "/").".jasper");
				$this->jasperReport = $this->jasperLoader->loadObject($this->file);
			} catch(\JavaException $e) {
				echo $e->getTraceAsString();
			}*/
			try {			
				$this->file = new \Java("java.io.File", $fname);
				$this->jrDesign = $this->jrxmloader->load($this->file);
				$this->jasperReport = $this->jcm->compileReport($this->jrDesign);
			} catch(\Exception $e) {
				echo $e->toString();
				return null;
			}
			
			/* set Parameters */
			foreach($rptparams as $name => $val) {
				$this->params->put($name, "$val");
			}
			$subPath = $this->getSubReportRoot($rptname);
			$this->params->put("SUBREPORT_DIR", $subPath);
			$imagePath = $this->path.'/images/';
			//if($rpttype == 'Html') $imagePath = '../reports/images/';		
			$this->params->put("IMAGES_PATH", $imagePath);
			$this->params->put("RPT_TYPE", $rpttype);
			$this->params->put($this->jrParameter->REPORT_LOCALE, $this->locale);
			$rrs = $this->requestReportStorage;
			if(isset($rrs["REQUEST_BY_ID"])) $this->params->put("PNIP", $rrs["REFERENSI"]["TTD_OLEH"]["NIP"]);
			else {
				if(!empty($config["USER_NIP"])) $this->params->put("PNIP", $config["USER_NIP"]);
			}
			if(!empty($rrs["TTD_OLEH"])) {
				$this->params->put("REQUEST_REPORT_ID", System::toUUIDEncode($rrs["ID"]));
				if($dsc && $config["TTE_CONFIG"]) {
					if(isset($dsc["PIN"])) $this->params->put("TTE", $config["TTE_CONFIG"]["footer"]);
				}
			}
			$cfg = $this->controller->getConfig();
			$docs = false;
			if(isset($cfg["DocumentStorage"])) {			
				$ds = $cfg["DocumentStorage"];
				if($ds) $this->params->put("DS_CONFIG", json_encode($ds));
				$docs = true;
				if(isset($ds["verifikasi"])) {
					if(isset($ds["verifikasi"]["url"])) $this->params->put("DOCUMENT_VERIFICATION_URL", $ds["verifikasi"]["url"]);
				}
			}
		}
		
		try {
			if(!$fileInfo["exists"]) {
				$this->jasperPrint = $this->fillManager->fillReport($this->jasperReport, $this->params, $conn);        
				$this->jasperPrint->setLocaleCode($this->localeCode);
			}
			$clsName = 'ReportService\\'.$rpttype;
			$params = [
				"requestId" => $config["REQUEST_ID"],
				"response" => $response,
				"rptName" => $rptname,
				"rptExt" => $rptext,
				"jasperPrint" => $this->jasperPrint,
				"rootPath" => $this->path,
				"rptFileName" => $rptFileName,
				"print" => $requestPrint,
				"config" => $config,
				"controller" => $this->controller,
				"requestReportStorage" => $this->requestReportStorage,
				"fileInfo" => $fileInfo
			];
			if($docs) {
				if($rpttype != "Pdf") {					
					if($rrs) {
						$clsName = 'ReportService\\Pdf';
						$params["rptext"] = "pdf";
						$params["responseEmpty"] = true;
						$rpt = new $clsName($params);
						$id = $rpt->toReport();
						return $id;
					}
				}
			}
			$obj = new $clsName($params);
			$id = $obj->toReport();
			return $id;
		} catch(\Exception $e) {
			echo $e->toString();
			return null;
		}
	}

	public function createFromJson($response, $jsonString, $rptname, $rpttype, $rptext, $rptFileName, $requestPrint) {
		try {			
			$json = new \Java("java.lang.String", $jsonString);
			$stream = new \Java("java.io.ByteArrayInputStream", $json->getBytes());
			$this->params->put($this->jsonQueryExecuterFactory->JSON_INPUT_STREAM, $stream);
			$this->file = new \Java("java.io.File", $this->path."/".$this->replace($rptname, ".", "/").".jrxml");
			$this->jrDesign = $this->jrxmloader->load($this->file);
			$this->jasperReport = $this->jcm->compileReport($this->jrDesign);
		} catch(\Exception $e) {
			echo $e->toString();
		}
		
		/* set Parameters */
        $subPath = $this->getSubReportRoot($rptname);
        $this->params->put("SUBREPORT_DIR", $subPath);
		$imagePath = $this->path.'/images/';
		//if($rpttype == 'Html') $imagePath = '../reports/images/';		
		$this->params->put("IMAGES_PATH", $imagePath);
        $this->params->put("RPT_TYPE", $rpttype);
        $this->params->put($this->jrParameter->REPORT_LOCALE, $this->locale);
		
		try {
			$this->jasperPrint = $this->fillManager->fillReport($this->jasperReport, $this->params);
			$this->jasperPrint->setLocaleCode($this->localeCode);
			$clsName = 'ReportService\\'.$rpttype;
			$params = [
				"response" => $response,
				"rptName" => $rptname,
				"rptExt" => $rptext,
				"jasperPrint" => $this->jasperPrint,
				"rootPath" => $this->path,
				"rptFileName" => $rptFileName,
				"print" => $requestPrint
			];
			$obj = new $clsName($params);
			$obj->toReport();
		} catch(\Exception $e) {
			echo $e->toString();
		}
	}
		
	private function reportInit() {
		$this->jrxmloader = java("net.sf.jasperreports.engine.xml.JRXmlLoader");
		$this->jrDesign = java("net.sf.jasperreports.engine.design.JasperDesign");

		$this->jasperLoader = java("net.sf.jasperreports.engine.util.JRLoader");
        $this->jasperReport = java("net.sf.jasperreports.engine.JasperReport");
		
		$this->jrParameter = java("net.sf.jasperreports.engine.JRParameter");
        
        $this->params = new \Java("java.util.HashMap");
		
		$this->fillManager = java("net.sf.jasperreports.engine.JasperFillManager");
		
		$this->jcm = new \JavaClass("net.sf.jasperreports.engine.JasperCompileManager");
		$this->jsonQueryExecuterFactory = java("net.sf.jasperreports.engine.query.JsonQueryExecuterFactory");
	}

	private function getInfofileReport() {
		$exists = false;
		$path = "";
		$name = "";
		if($this->requestReportStorage) {
			if($this->requestReportStorage["STATUS"] == 2) {
				$tgl = $this->requestReportStorage["DIBUAT_TANGGAL"];
				$tgls = explode(" ", $tgl);
				$tgls = explode("-", $tgls[0]);
				$path = "reports/output/".$tgls[0]."/".$tgls[1]."/".$tgls[2];
				$name = $this->requestReportStorage["ID"];
				if(file_exists($path."/".$name)) $exists = true;
			}
		}

		return [
			"exists" => $exists,
			"path" => $path,
			"name" => $name
		];
	}
	
	private function getReportRoot() {
        return realpath(".")."/reports";
    }
	
	private function getSubReportRoot($rptnm) {
        $path = $this->getReportRoot();
        $subPath = explode(".", $rptnm);
		array_pop($subPath);
        $subPath = implode("/", $subPath);        
        $path = explode("/", $path.(isset($subPath) && strlen($subPath) != 0 ? "/".$subPath : ""));
        $path = implode("/", $path);
        return $path."/";
    }
	
	private function replace($data, $search, $replace) {
        $data = explode($search, $data);
        return $data = implode($replace, $data);
    }
}
