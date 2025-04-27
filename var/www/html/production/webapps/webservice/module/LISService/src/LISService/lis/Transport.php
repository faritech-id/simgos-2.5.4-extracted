<?php
namespace LISService\lis;

use LISService\lis\DriverInterface;

use LISService\lis\orderitemlog\Service as OrderItemLogService;
use LISService\lis\hasillog\Service as HasilLogService;
use Layanan\V1\Rest\TindakanMedis\TindakanMedisService;
use Layanan\V1\Rest\OrderLab\OrderLabService;

/**
 * @author admin
 * @version 1.0
 * @created 26-Mar-2016 17.43.00
 */
class Transport
{
	private $hasilLog;
	private $orderItemLog;
	private $tindakanMedis;
	private $orderLab;
	
	private $driver;
	private $config;
	
	public function __construct($driverName, $config) {		
		$this->driver = new $driverName();
		$this->config = $config;

		if(isset($config["fieldStatusResults"])) {
			if(is_array($config["fieldStatusResults"])) {
				$fields = $config["fieldStatusResults"];
				$id = $this->driver->getVendorId();
				if(isset($fields[$id])) {
					if(!empty($fields[$id])) $this->driver->setFieldStatusResult($fields[$id]);
				}
			}
		}
		
		$this->orderItemLog = new OrderItemLogService();
		$this->hasilLog = new HasilLogService();
		$this->tindakanMedis = new TindakanMedisService();
		$this->orderLab = new OrderLabService();
	}
	
	public function getResult() {
		$data = $this->driver->getResult();	
		foreach($data as $row) {
			$cek = $this->hasilLog->load([
				"LIS_NO" => $row["LIS_NO"], 
				"LIS_NAMA_TEST" => $row["LIS_NAMA_TEST"]
			]);
			if(count($cek) > 0) {
				$row["ID"] = $cek[0]["ID"];
				$row["STATUS"] = 1;
			}
			$this->hasilLog->simpanData($row, count($cek) == 0, false);
			$this->driver->updateStatusResult($row);			
		}
		return $data;
	}
	
	public function order() {
		$data = $this->orderItemLog->load(["STATUS" => 1], ['*'], ['TANGGAL ASC']);
		foreach($data as $row) {
			$tm = $this->tindakanMedis->load(["tindakan_medis.ID" => $row["HIS_ID"]]);
			$nomor = $tm[0]["REFERENSI"]["KUNJUNGAN"]["REF"];
			if($nomor != null) {
				$order = $this->orderLab->load(["order_lab.NOMOR" => $nomor]);
				if(count($order) > 0) $tm[0]["REFERENSI"]["ORDER_LAB"] = $order[0];
			}
			$this->driver->order($tm[0]);
			$this->updateStatusOrder($row);
		}
		return $data;
	}
	
	private function updateStatusOrder($order) {
		$order["STATUS"] = 2;
		$this->orderItemLog->simpanData($order, false, false);
	}
}