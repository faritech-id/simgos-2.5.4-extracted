<?php
namespace ReportService;

class Pdf extends ReportType
{
	private $rssId;

	protected function reportInit() {
		$this->export =new \Java("net.sf.jasperreports.engine.export.JRPdfExporter");
	}
	
	protected function reportSetting() {
		$this->outputPath = $this->rootPath.$this->requestId;
		if($this->requestReportStorage) {
			$this->rssId = $this->requestReportStorage["ID"];
			$this->outputPath = $this->rootPath.$this->rssId;
		}
		$title = isset($this->config["TITLE"]) ? $this->config["TITLE"] : $this->rptName;
		$this->file = new \Java("java.io.File", $this->outputPath);
		$this->sei = new \Java("net.sf.jasperreports.export.SimpleExporterInput", $this->jasperPrint);
		$this->soseo = new \Java("net.sf.jasperreports.export.SimpleOutputStreamExporterOutput", $this->file);
		$this->export->setExporterInput($this->sei);
		$this->export->setExporterOutput($this->soseo);

		$this->configuration = new \Java("net.sf.jasperreports.export.SimplePdfExporterConfiguration");
		$this->configuration->setMetadataTitle($title);
    	$this->configuration->setMetadataCreator("simgos2");

		$instansi = $this->instansi->load()[0];
		$ppk = $instansi["REFERENSI"]["PPK"];
		$this->configuration->setMetadataAuthor($ppk["KODE"]." - ".$ppk["NAMA"]);
		$this->export->setConfiguration($this->configuration);
	}
	
	protected function download() {
		$id = null;
		$tgl = null;
		$success = false;
		$title = isset($this->config["TITLE"]) ? $this->config["TITLE"] : $this->rptName;
		if($this->fileInfo["exists"]) {
			$content = file_get_contents($this->fileInfo["path"]."/".$this->fileInfo["name"]);
			$content = base64_decode($content);
			$content = str_replace("data:application/pdf;base64,", "", $content);
			$content = base64_decode($content);
		}
		if(!$this->fileInfo["exists"]) {
			exec("sudo chmod 775 -Rf ".$this->outputPath);
			$content = file_get_contents($this->outputPath);
			//$content = $this->setPdfTitle($content, $title);
		}
		
		$oriContent = $content;

		try {
			if($this->requestReportStorage) {				
				$cfg = $this->controller->getConfig();
				$ds = null;
				$tte = null;
				$content = "data:application/pdf;base64,".base64_encode($content);
				$content = base64_encode($content);
				if(isset($cfg["DocumentStorage"])) $ds = $cfg["DocumentStorage"];
				if(isset($cfg["tte"])) $tte = $cfg["tte"];
				if($ds) {
					if(!empty($this->requestReportStorage["TTD_OLEH"])) {
						$id = $this->requestReportStorage["ID"];
						$tgl = $this->requestReportStorage["DIBUAT_TANGGAL"];
						$nik = $this->requestReportStorage["REFERENSI"]["TTD_OLEH"]["NIK"];
						if($this->requestReportStorage["STATUS"] == 2) {
							$params = [
								"NAME" => $title,
								"EXT" => "pdf",
								"DOCUMENT_DIRECTORY_ID" => $this->requestReportStorage["DOCUMENT_DIRECTORY_ID"],
								"REFERENCE_ID" => $this->requestReportStorage["REF_ID"],
								"CREATED_BY" => $this->requestReportStorage["NAMA_USER"],
								"DATA" => $content
							];

							// sign bsre
							if($tte) {
								$pds = (array) $this->config["DOCUMENT_STORAGE"];
								if(isset($pds["PIN"])) {
									if($pds["PIN"]) {
										$tgls = explode(" ", $tgl);
										$tgls = explode("-", $tgls[0]);
										$path = "reports/output/tte_tmp/".$tgls[0]."/".$tgls[1]."/".$tgls[2];
										$file = $path."/".$id.".pdf";
										$signFile = $path."/".$id."_sign.pdf";
										exec("sudo mkdir -p ".$path);
										exec("sudo chmod 777 -Rf ".$path);
										file_put_contents($file, $oriContent);

										$result = $this->controller->doSendRequest([
											"url" => $tte["url"],
											"action" => "sign",
											"method" => "POST",
											"data" => [
												"nik" => $nik,
												"passphrase" => $pds["PIN"],
												"file_location" => $file,
												"refId" => $id,
												"refJenis" => 1,
												"url" => $ds["verifikasi"]["url"]
											]
										]);
										if($result) {
											unlink($file);
											$result = (array) $result;
											if($result["status"] == 200) {
												$oriContent = file_get_contents($signFile);
												$content = "data:application/pdf;base64,".base64_encode($oriContent);
												$content = base64_encode($content);
												$params["DATA"] = $content;
												unlink($signFile);
											} else {
												$info = "<span style='font-weight: bold'>Tanda Tangan Elektronik: </span><br/>"
													."<span style='font-size: 24px; font-style: italic'>".$result["status"].": ".$result["detail"]."</span>";
												echo $info;
												unlink($this->outputPath);
												return;
											}
										} else {
											$info = "<span style='font-weight: bold'>Tanda Tangan Elektronik: </span><br/>"
													."<span style='font-size: 24px; font-style: italic'>Gagal terhubung dengan penyedia TTE</span>";
											echo $info;
											unlink($this->outputPath);
											return;
										}
									}
								}
							}
							if(isset($this->requestReportStorage["REVISION_FROM"])) $params["REVISION_FROM"] = $this->requestReportStorage["REVISION_FROM"];
							$ctrl = clone $this->controller;

							if(empty($ds["remote"])) {
								$tgls = explode(" ", $tgl);
								$tgls = explode("-", $tgls[0]);
								$path = "reports/output/store_tmp/".$tgls[0]."/".$tgls[1]."/".$tgls[2];
								$file = $path."/".$id;
								exec("sudo mkdir -p ".$path);
								exec("sudo chmod 777 -Rf ".$path);
								file_put_contents($file, $params["DATA"]);
								$params["FILE_LOCATION"] = $file;
								unset($params["DATA"]);
							}
							
							$result = $ctrl->doSendRequest([
								"url" => $ds["url"],
								"action" => "document",
								"method" => "POST",
								"data" => $params
							]);
							
							if($result) {
								if(empty($ds["remote"])) unlink($file);
								$result = (array) $result;
								if($result["status"] == 200) {
									$success = true;
									$this->documentStorageId = $result["data"]->ID;									
								} else {
									$info = "<span style='font-weight: bold'>Media Penyimpanan Dokumen: </span><br/>"
											."<span style='font-size: 24px; font-style: italic'>".$result["status"].": ".$result["detail"]."</span>";
									echo $info;
									unlink($this->outputPath);
									return;
								}
							} else {
								if(empty($ds["remote"])) unlink($file);
								$info = "<span style='font-weight: bold'>Media Penyimpanan Dokumen: </span><br/>"
										."<span style='font-size: 24px; font-style: italic'>Gagal terhubung ke MPD</span>";
								echo $info;
								unlink($this->outputPath);
								return;
							}
						}
					}
				}
			}
		} catch(\Exception $e) {
		} finally {
			if(!$success) {
				if($this->requestReportStorage) {
					if($this->requestReportStorage["STATUS"] == 2) {
						$tgls = explode(" ", $tgl);
						$tgls = explode("-", $tgls[0]);
						$path = "reports/output/".$tgls[0]."/".$tgls[1]."/".$tgls[2];
						exec("sudo mkdir -p ".$path);
						//file_put_contents($path."/".$id, $content);
					}
				}
			} else {
				if($this->fileInfo["exists"]) unlink($this->fileInfo["path"]."/".$this->fileInfo["name"]);
			}
			unlink($this->outputPath);
		}

		if(!$this->responseEmpty) {
			$name = $this->rptFileName;
			if($this->rssId) $name = $this->rssId;

			$this->response->setContent($oriContent);
			$headers = $this->response->getHeaders();
			$headers->addHeaderLine('Content-Type', "application/pdf")
			->addHeaderLine('Content-Length', strlen($oriContent))
			->addHeaderLine('Content-Disposition', 'inline; filename="'.$name.".".$this->rptExt.'"');
			return $response;
		}
	}

	private function setPdfTitle($content, $title) {
		$pos = strpos($content, "/Title");
		if(!$pos) {
			$pos = strpos($content, "/CreationDate");
			if($pos > -1) {
				$contents = substr($content, strpos($content, "/CreationDate"));
				$poscr = strpos($contents, "/", 1);
				$str = substr($contents, 0, $poscr);
				if($poscr > -1) {
					$newstr = $str."/Title (".$title.")";
					$content = str_replace($str, $newstr, $content);
				}
			}
		}

		return $content;
	}
}
