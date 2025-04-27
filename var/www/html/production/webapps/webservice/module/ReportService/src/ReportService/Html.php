<?php
namespace ReportService;

class Html extends ReportType
{
    private $htmlExportInput;
    private $htmlExportOutput;
    private $htmlConfig;
    private $enumSizeUnit;
    private $imageResource;
    private $root;
    private $imageDir;
		
	protected function reportInit() {
        $this->export = new \Java("net.sf.jasperreports.engine.export.HtmlExporter");        
        $this->enumSizeUnit = java("net.sf.jasperreports.export.type.HtmlSizeUnitEnum");        
    }    
	
	protected function reportSetting() {
        $this->root = str_replace("/reports", "", $this->rootPath);         
        $this->outputPath = $this->rootPath.$this->rptName.".".$this->rptExt;          

        $this->htmlExportInput = new \Java("net.sf.jasperreports.export.SimpleExporterInput", $this->jasperPrint);
        $this->htmlExportOutput = new \Java("net.sf.jasperreports.export.SimpleHtmlExporterOutput", $this->outputPath);

        $this->imageDir = $this->root."/public/images/";
        $file = new \Java("java.io.File", $this->imageDir);
        $this->imageResource = new \Java("net.sf.jasperreports.engine.export.FileHtmlResourceHandler", $file, "images/{0}");

        $this->htmlConfig = new \Java("net.sf.jasperreports.export.SimpleHtmlReportConfiguration");
        $this->htmlConfig->setSizeUnit($this->enumSizeUnit->POINT);
        $zoomRatio = new \Java("java.lang.Float", 1.0);
        $this->htmlConfig->setZoomRatio($zoomRatio);
        $this->htmlConfig->setUseBackgroundImageToAlign(false); 
        
        $this->htmlExportOutput->setImageHandler($this->imageResource);

        $this->export->setConfiguration($this->htmlConfig);
        $this->export->setExporterInput($this->htmlExportInput);
        $this->export->setExporterOutput($this->htmlExportOutput);
    }
    
    public function toReport() {
        if(file_exists($this->imageDir)) exec("sudo rm -Rf ".$this->imageDir);

        if(!file_exists($this->imageDir)) {
            exec("sudo mkdir ".$this->imageDir);
            exec("sudo chown tomcat:tomcat ".$this->imageDir);
            exec("sudo chmod 775 ".$this->imageDir);
        }

        $this->export->exportReport();
		if(!$this->print) $this->download();
        else $this->requestForPrint();
        
        exec("sudo chmod 775 -Rf ".$this->imageDir);
    }
}
