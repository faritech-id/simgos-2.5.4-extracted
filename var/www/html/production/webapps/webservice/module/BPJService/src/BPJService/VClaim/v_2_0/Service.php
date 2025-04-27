<?php
/**
 * BPJService
 * @author hariansyah
 * 
 */
 
namespace BPJService\VClaim\v_2_0;

use BPJService\VClaim\v_1_1\Service as BaseService;

class Service extends BaseService {
	protected $_rencanaKontrol;

	protected $pesertaservice;
	protected $sepservice;
	protected $refservice;
	protected $rujukanservice;
	protected $monitoringservice;
	protected $rkservice;
	protected $prbservice;
	protected $lpkservice;

	function __construct($config) {
		parent::__construct($config);		

		$this->pesertaservice = new PesertaService($config);
		$this->sepservice = new SEPService($config);
		$this->refservice = new ReferensiService($config);
		$this->rujukanservice = new RujukanService($config);
		$this->monitoringservice = new MonitoringService($config);
		$this->rkservice = new RencanaKontrolService($config);
		$this->prbservice = new PRBService($config);
		$this->lpkservice = new LPKService($config);
	}

	public function getPesertaService() {
		return $this->pesertaservice;
	}

	public function getSEPService() {
		return $this->sepservice;
	}

	public function getReferensiService() {
		return $this->refservice;
	}

	public function getRujukanService() {
		return $this->rujukanservice;
	}

	public function getMonitoringService() {
		return $this->monitoringservice;
	}

	public function getRencanaKontrolService() {
		return $this->rkservice;
	}

	public function getPRBService() {
		return $this->prbservice;
	}

	public function getLPKService() {
		return $this->lpkservice;
	}
}