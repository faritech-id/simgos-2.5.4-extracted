<?php
namespace LISService\novanet\dbservice;

use LISService\lis\DriverInterface;
use LISService\novanet\dbservice\result\Service as ResultService;
use \Exception;

/**
 * @author admin
 * @version 1.0
 * @created 26-Mar-2016 17.43.00
 */
class Driver implements DriverInterface
{	
	private $result;
	private $fieldStatusResult = "Status";
	
	public function __construct()
	{		
		$this->result = new ResultService();
	}

	public function setFieldStatusResult($fieldName) {
		$this->fieldStatusResult = $fieldName;
		$this->result->setFieldStatusResult($fieldName);
	}

	public function getResult()
	{
		$data = [];
		$fieldStatus = $this->fieldStatusResult;
		// $result = $this->result->load(["result.status" => ["F","W","J"]]); or
		// ["result.status IN ('F','W','J') AND NOT o.InstrID = 'Novanet'"]				
		$result = $this->result->load(
			["Result.$fieldStatus IN ('F','W','J')"],
			[
				"_OID", "InstrTestID", "InstrTestName", "RValue",
				"NatureAnormalTest", "HL_Limit", "AHL_Limit", "ANormalFlag", "Unit",
				"TestEndDate", "OperatiorID"
			],
			["TestEndDate"]
		);
				
		foreach($result as $row) {
			$data[] = [
				'LIS_NO'=>$row['_OID'],
				'HIS_NO_LAB'=>'',
				'LIS_KODE_TEST'=>$row['InstrTestID'],
				'LIS_NAMA_TEST'=>($row['InstrTestName'] == '' || $row['InstrTestName'] == null ? $row['InstrTestID'] : $row['InstrTestName']),
				'LIS_HASIL'=>$row['RValue'],
				'LIS_CATATAN'=>$row['NatureAnormalTest'],
				'LIS_NILAI_NORMAL'=>trim($row['HL_Limit']." ~ ".$row['AHL_Limit']),
				'LIS_FLAG'=>$row['ANormalFlag'],
				'LIS_SATUAN'=>$row['Unit'], 
				'LIS_NAMA_INSTRUMENT'=>$row['InstrID'], 
				'LIS_TANGGAL'=>$row['TestEndDate'], 
				'LIS_USER'=>$row['OperatiorID'], 
				'HIS_KODE_TEST'=>'',
				'REF'=>$row['Lab_PatientID'], 
				'VENDOR_LIS'=>$this->getVendorId(),
				'LIS_LOKASI'=>($row['InstrID'] == 'Novanet' ? $row['Location'] : $row['DeviceID'])
			];
		}
		
		return $data;
	}
	
	public function updateStatusResult($data)
	{
		$fieldStatus = $this->fieldStatusResult;
		$params = [
			"_OID" => $data["LIS_NO"],
			"$fieldStatus" => "R"
		];
		if($data["LIS_NAMA_INSTRUMENT"] == 'Novanet') {
			$params["InstrTestName"] = $data["LIS_NAMA_TEST"];
		} else {
			$params["InstrTestID"] = $data["LIS_KODE_TEST"];
		}
		
		$this->result->simpan($params);
	}

	public function order($params=[])
	{
		throw new \Exception(
			'Order Not Support'
		);
	}

	public function dbStatus() {
		$fieldStatus = $this->fieldStatusResult;
		$this->result->load(["Result.$fieldStatus IN ('F','W','J')"]);
	}
	
	public function getVendorId(){
		return 2;
	}
}
?>