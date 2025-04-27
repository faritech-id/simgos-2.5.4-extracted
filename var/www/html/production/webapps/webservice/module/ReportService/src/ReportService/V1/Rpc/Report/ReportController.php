<?php
namespace ReportService\V1\Rpc\Report;

use DBService\RPCResource;
use Laminas\ApiTools\ApiProblem\ApiProblem;

use DBService\Crypto;

class ReportController extends RPCResource
{
	private $rs;
    
    public function __construct($rs) {
        $this->rs = $rs;
		$this->config = $this->rs->getConfig();
		$this->rs->setController($this);
    }
	
    public function reportAction()
    {		
		/* get Request Report Parameters 
			$requestReport = array(
				'NAME' => 'pasien.Test',
				'CONNECTION_NUMBER' => 0,
				'TYPE' => 'Html',
				'EXT' => 'html',
				'PARAMETER'=>array(
					'NAMA' => 'Hariansyah',
					'PRINT_HEADER' => false
				),
				'REQUEST_FOR_PRINT' => false
			);
		*/
		
		$action = $this->getRequest()->getQuery('action');	
		
		if($action) {
			if($action == "generatekey") {
				return $this->generateKey32bit($this->getRequest()->getQuery());
			}

			if($action == "test") {
				return $this->testReportJson();
			}

			if($action == "requestDecrypt") {
				$key = $this->getRequest()->getQuery('key');
				$data = $this->getRequest()->getQuery('data');
				return $this->requestDecrypt($key, $data);
			}
		}			
		
		$var = $this->getRequest()->getQuery('requestReport');
		if(empty($var)) {
			$api = new ApiProblem(412, "Parameter request tidak valid");
			$data = $api->toArray();
			$this->response->setStatusCode($api->__get('status'));
			return $data;
		}
		$this->rs->setTteConfig((array) $this->getPropertyConfig(87, "json"));
		$result = $this->rs->generate($this->getResponse(), $var);
		return $result;
    }

	public function generateKey32bit($params) {
		$crypto = new Crypto();
		$key = $crypto->generateKey($params["pass"]);
		
		return array(
			"key" => $key
		);
	}

	public function testReportJson() {
		$data = [[
			"KODERS" => "7371325",
			"NAMAINST" => "RSUP. Dr. Wahidin Sudirohusodo",
			"KODEPROP" => "7371",
			"KOTA" => "MAKASSAR",
			"TAHUN" => 2021,
			"AWAL" => 94,
			"MASUK" => 0,
			"PINDAHAN" => 0,
			"DIPINDAHKAN" => 0,
			"HIDUP" => 0,
			"MATI" => 0,
			"MATIKURANG48" => 0,
			"MATILEBIH48" => 0,
			"LD" => 0,
			"SISA" => 0,
			"HP" => 0,
			"JMLTT" => 0,
			"BOR" => 0,
			"BORLK" => 0,
			"BORPR" => 0,
			"AVLOS" => 0,
			"AVLOSLK" => 0,
			"AVLOSPR" => 0,
			"BTO" => 0,
			"BTOLK" => 0,
			"BTOPR" => 0,
			"TOI" => 0,
			"TOILK" => 0,
			"TOIPR" => 0,
			"NDR" => 0,
			"NDRLK" => 0,
			"NDRPR" => 0,
			"GDR" => 0, 
			"GDRLK" => 0,
			"GDRPR" => 0,
			"JMLKUNJUNGAN" => 0.00
		]];
		$report = $this->rs->getReport();
		$response = $this->getResponse();
		$report->createFromJson($response, json_encode($data), "rl.7371325-LaporanRL12JSON", "Pdf", "pdf", "", false);
		return $response;
	}

	public function requestDecrypt($key, $data)
    {
		$crypto = new Crypto();
		$crypto->setKey($key);
		$encode = $crypto->encrypt(
			base64_encode(
				json_encode(
					["data" => "Hello"]
				)
			), false
		);

		$decode = $crypto->decrypt($encode, false);
		$decode = json_decode(base64_decode($decode));

		return [
			"encode" => $encode,
			"decode" => $decode
		];
	}
}
