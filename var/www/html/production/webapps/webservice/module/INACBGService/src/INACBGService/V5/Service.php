<?php
/**
 * INACBGService
 * @author hariansyah
 * 
 */
namespace INACBGService\V5;
	
use INACBGService\V1\Rest\HasilGrouping\HasilGroupingService;
use INACBGService\V1\Rest\Inacbg\InacbgService;

use INACBGService\Crypto;

use Aplikasi\db\bridge_log\Service as BridgeLogService;
use DBService\generator\Generator;

class Service {
	private $config;
	private $adapter;
	private $hasilGrouping;
	protected $bridgeLog;
	protected $jenisBridge = 2;
	protected $refInacbg;
	
	function __construct($config, $adapter) {
		$this->config = $config;
		$this->adapter = $adapter;
		
		$this->hasilGrouping = new HasilGroupingService();
		$this->refInacbg = new InacbgService();
		$this->bridgeLog = new BridgeLogService();
	}

	protected function writeBridgeLog($data=[]) {
		if(!isset($this->config["writeLog"])) return false;
		if(!$this->config["writeLog"]) return false;
		$isCreate = isset($data["ID"]) ? false : true;
		if($isCreate) $data["ID"] = Generator::generateIdBridgeLog();
		$data["JENIS"] = $this->jenisBridge;
		$this->bridgeLog->simpanData($data, $isCreate);
		return $data["ID"];
	}
	
	private function sendRequest($method = "GET", $data = "", $contenType = "application/json", $url = "") {
		$curl = curl_init();
		
		$headers = array(
			"Accept: application/Json"
		);		
		
		$url = ($url == '' ? $this->config["url"] : $url);

		$headers[count($headers)] = "Content-type: ".$contenType;
		$headers[count($headers)] = "Content-length: ".strlen($data);

		$id = $this->writeBridgeLog([
			"URL" => $url,
			"HEADERS" => json_encode($headers),
			"REQUEST" => $data,
			"ACCESS_FROM_IP" => $_SERVER['REMOTE_ADDR']
		]);
		
		curl_setopt($curl, CURLOPT_URL, $url);
		curl_setopt($curl, CURLOPT_HEADER, false);
		curl_setopt($curl, CURLOPT_CUSTOMREQUEST, $method);
		curl_setopt($curl, CURLOPT_POSTFIELDS, $data);
		
		//curl_setopt($curl, CURLOPT_FAILONERROR, true); 
		curl_setopt($curl, CURLOPT_FOLLOWLOCATION, true); 
		curl_setopt($curl, CURLOPT_RETURNTRANSFER, true); 
		curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, false); 
		curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false); 
		curl_setopt($curl, CURLOPT_HTTPHEADER, $headers);
		
		$result = curl_exec($curl);
		
		curl_close($curl);

		$this->writeBridgeLog([
			"ID" => $id,
			"RESPONSE" => $result
		]);
		
		return $result;
	}

	/**
	  * @method generateNomorKlaim
	  * @param $data array
	  * 1. Generate Nomor Klaim
	  * => Data Request
	  * {
	  *		"metadata": {
	  *			"method": "generate_claim_number"
	  *		},
	  *		"data": {
	  *			"payrol_id": "71"
	  *		}
	  *	}
	  * @return data response
	  * => Data Response
	  * {
	  *		"metadata": {
	  *			"code":"200",
	  *			"message":"Ok"
	  *		},
	  *		"response": {
	  *			"claim_number":"0000005ICC200483B9"
	  *		}
	  *	}
	  *
	 */		
	public function generateNomorKlaim($data = []) {
		$request = [
			"metadata" => [
				"method" => "generate_claim_number"
			]
		];
		
		$data = json_encode($request);		
		$data = Crypto::encrypt($data, $this->config["key"]);
		
		$result = $this->sendRequest("POST", $data, "application/json");
		$result = Crypto::decrypt($result, $this->config["key"]);
		
		return json_decode($result);
	}
	
	/**
	  * @method klaimBaru
	  * @param $data array
	  * 1. Membuat Klaim baru
	  * => Data Request
	  * {
	  *		"metadata": {
	  *			"method": "new_claim"
	  *		},
	  *		"data": {
	  *			"nomor_kartu": "0000668873981",
	  *			"nomor_sep": "0301R00112140006067",
	  *			"nomor_rm": "123-45-67",
	  *			"nama_pasien": "SATINI",
	  *			"tgl_lahir": "1940-01-01 02:00:00",
	  *			"gender": "1=L;2=P"
	  *		}
	  *	}
	  * @return data response
	  * => Data Response
	  * {
	  *		"metadata": {
	  *			"code":"200",
	  *			"message":"OK"
	  *		}
	  *	}
	  *	Jika ada duplikasi nomor SEP:
	  *	{
	  *		"metadata": {
	  *			"code": 400,
	  *			"message": "Duplikasi nomor SEP"
	  *		}
	  *	}
	 */		
	public function klaimBaru($data = array()) {
		$request = array(
			"metadata" => array(
				"method" => "new_claim"
			),
			"data" => $data
		);
		
		$data = json_encode($request);		
		$data = Crypto::encrypt($data, $this->config["key"]);
		
		$result = $this->sendRequest("POST", $data, "application/json");
		$result = Crypto::decrypt($result, $this->config["key"]);
		
		return json_decode($result);
	}
	
	/**
	  * @method updateDataPasien
	  * @param $data array
	  * 1. Membuat Update Data Pasien
	  * => Data Request
	  * {
	  *		"metadata": {
	  *			"method": "update_patient",
	  *			"nomor_rm": "123-45-67"
	  *		},
	  *		"data": {
	  *			"nomor_kartu": "0000668873981",
	  *			"nomor_rm": "123-45-67",
	  *			"nama_pasien": "SATINI",
	  *			"tgl_lahir": "1940-01-01 02:00:00",
	  *			"gender": "1=L;2=P"
	  *		}
	  *	}
	  * @return data response
	  * => Data Response
	  * {
	  *		"metadata": {
	  *			"code":"200",
	  *			"message":"OK"
	  *		}
	  *	}
	  *	Jika ada duplikasi nomor SEP:
	  *	{
	  *		"metadata": {
	  *			"code": 400,
	  *			"message": "Duplikasi nomor SEP"
	  *		}
	  *	}
	 */		
	public function updateDataPasien($data = array()) {
		$request = array(
			"metadata" => array(
				"method" => "update_patient",
				"nomor_rm" => $data["nomor_rm"]
			),
			"data" => $data
		);
		
		$data = json_encode($request);
		$data = Crypto::encrypt($data, $this->config["key"]);
		
		$result = $this->sendRequest("POST", $data, "application/json");
		return json_decode(Crypto::decrypt($result, $this->config["key"]));
	}
	
	/**
	  * @method hapusDataPasien
	  * @param $data array
	  * 1. Membuat Hapus Data Pasien
	  * => Data Request
	  * {
	  *		"metadata": {
	  *			"method": "delete_patient"
	  *		},
	  *		"data": {
	  *			"nomor_rm": "123-45-67",
	  *			"coder_nik": "123123123123"
	  *		}
	  *	}
	  * @return data response
	  * => Data Response
	  * {
	  *		"metadata": {
	  *			"code":"200",
	  *			"message":"OK"
	  *		}
	  *	}	 
	 */		
	public function hapusDataPasien($data = array()) {
		$request = array(
			"metadata" => array(
				"method" => "delete_patient"
			),
			"data" => $data
		);
		
		$data = json_encode($request);
		$data = Crypto::encrypt($data, $this->config["key"]);
		
		$result = $this->sendRequest("POST", $data, "application/json");
		return json_decode(Crypto::decrypt($result, $this->config["key"]));
	}
	
	/**
	  * @method updateDataKlaim
	  * @param $data array
	  * 2. Untuk mengisi/update data klaim:
	  * => Data Request
	  * {
	  *		"metadata": {
	  *			"method": "set_claim_data",
	  *			"nomor_sep": "0301R00112140006067"
	  *		},
	  *		"data": {
	  *			"nomor_sep": "0301R00112140006067",
	  *			"nomor_kartu": "0301R00112140006067",
	  *			"tgl_masuk": "2015-07-01 07:00:00",
	  *			"tgl_pulang": "2016-01-07 15:00:00",
	  * #NEW 5.8.x
	  *			"cara_masuk": "gp",

	  *			"jenis_rawat": "1",
	  *			"kelas_rawat": "3",
	  *			"adl_sub_acute": "15",
	  *			"adl_chronic": "12",
	  *			"icu_indikator": "1",
	  *			"icu_los": "2",
	  *			"ventilator_hour": "5",
	  * #NEW 5.8.x
	  *			"ventilator": {,
	  *				"use_ind": "1",
	  *				"start_dttm": "2023-01-26 12:55:00",
	  *				"stop_dttm": "2023-01-26 17:50:00",
	  *			},

	  *			"upgrade_class_ind": "1",
	  *			"upgrade_class_class": "vip",
	  *			"upgrade_class_los": "5",
	  *			"add_payment_pct": "1000000",
	  * #NEW 5.8.x
	  *			"upgrade_class_payor": "peserta",
	  *			"sistole": "120",
	  *			"diastole": "70",
	  
	  *			"birth_weight": "",
	  *			"discharge_status": "1",
	  *			"diagnosa": S71.0#A00.1",
	  *			"procedure": "81.52#88.38#86.22",
	  
	  * #NEW INA Grouper
	  *			"diagnosa_inagrouper": "S71.0#A00.1",    
	  *			"procedure_inagrouper": "81.52#88.38#86.22+3",

	  *			"tarif_rs": "2500000", // FOR INACBG BEFORE
	  * ADD NEW FIELD INACBG 5.2 DISTRIBUSI TARIF RS
	  *			"tarif_rs" : {
	  *				"prosedur_non_bedah": 0,	
	  *				"prosedur_bedah": 0,		
	  *				"konsultasi": 0,
	  *				"tenaga_ahli": 0,	
	  *				"keperawatan": 0,		
	  *				"penunjang": 0,			
	  *				"radiologi": 0,
	  *				"laboratorium": 0,	
	  *				"pelayanan_darah": 0,	
	  *				"rehabilitasi": 0,		
	  *				"kamar": 0,
	  *				"rawat_intensif": 0,	
	  *				"obat": 0,
	  *             "obat_kronis": 0,          #ADD 5.3
	  *             "obat_kemoterapi": 0,      #ADD 5.3				
	  *				"alkes": 0, 
	  *				"bmhp": 0,			
	  *				"sewa_alat": 0,
	  *			}

	  * #NEW 2020-04-20
	  *			"pemulasaraan_jenazah": "1",
 	  *			"kantong_jenazah": "1",
  	  *			"peti_jenazah": "1",
  	  *			"plastik_erat": "1",
  	  *			"desinfektan_jenazah": "1",
  	  *			"mobil_jenazah": "0",
  	  *			"desinfektan_mobil_jenazah": "0",
  	  *			"covid19_status_cd": "1",
  	  *			"nomor_kartu_t": "nik",
  	  *			"episodes": "1;12#2;3#6;5",
	  *			"covid19_cc_ind": "1",
	  * #NEW 2020-08-13
	  *			"covid19_rs_darurat_ind": "1",
	  *			"covid19_co_insidense_ind": "1",
	  *			"covid19_no_sep": "",
	  *			"covid19_penunjang_pengurang": {,
	  *				"lab_asam_laktat": "1",
	  *				"lab_procalcitonin": "1",
	  *				"lab_crp": "1",
	  *				"lab_kultur": "1",
	  *				"lab_d_dimer": "1",
	  *				"lab_pt": "1",
	  *				"lab_aptt": "1",
	  *				"lab_waktu_pendarahan": "1",
	  *				"lab_anti_hiv": "1",
	  *				"lab_analisa_gas": "1",
	  *				"lab_albumin": "1",
	  *				"rad_thorax_ap_pa": "1"
	  *			},

	  * #NEW 2021-07-12
	  *			"terapi_konvalesen": "1000000",
	  *			"akses_naat": "C",
      *			"isoman_ind": "0",
	  *			"bayi_lahir_status_cd": 1,
	  * #NEW 5.8.x
	  *			"dializer_single_use": "0",
	  *			"kantong_darah": 1,
	  *			"apgar": {
	  *				"menit_1": {
	  *					"appearance": 1,
	  *					"pulse": 2,
	  *					"grimace": 1,
	  *					"activity": 1,
	  *					"respiration": 1
	  *				},
	  *				"menit_5": {
	  *					"appearance": 2,
	  *					"pulse": 2,
	  *					"grimace": 2,
	  *					"activity": 2,
	  *					"respiration": 2
	  *				}
	  *			},
	  *			"persalinan": {
	  *				"usia_kehamilan": "22",
	  *				"gravida": "2",
	  *				"partus": "4",
	  *				"abortus": "2",
	  *				"onset_kontraksi": "induksi",
	  *				"delivery": [
	  *					{
	  *						"delivery_sequence": "1",
	  *						"delivery_method": "vaginal",
	  *						"delivery_dttm": "2023-01-21 17:01:33",
	  *						"letak_janin": "kepala",
	  *						"kondisi": "livebirth",
	  *						"use_manual": "1",
	  *						"use_forcep": "0",
	  *						"use_vacuum": "1",
	  *						"shk_spesimen_ambil": "tidak", // ya | tidak
	  *						"shk_lokasi": "", // tumit | vena
	  *						"shk_alasan": "", // tidak-dapat | akses-sulit
	  *						"shk_spesimen_dttm": "", // tanggal pengambilan spesimen iso dttm
	  *					},
	  *					{
	   *					"delivery_sequence": "2",
	  *						"delivery_method": "vaginal",
	  *						"delivery_dttm": "2023-01-21 17:03:49",
	  *						"letak_janin": "lintang",
	  *						"kondisi": "livebirth",
	  *						"use_manual": "1",
	  *						"use_forcep": "0",
	  *						"use_vacuum": "0",
	  *						"shk_spesimen_ambil": "tidak", // ya | tidak
	  *						"shk_lokasi": "", // tumit | vena
	  *						"shk_alasan": "", // tidak-dapat | akses-sulit
	  *						"shk_spesimen_dttm": "", // tanggal pengambilan spesimen iso dttm
	  *					}
	  *				]
	  *			},

	  *			"tarif_poli_eks": "2500000",
	  *			"nama_dokter": "dr. Erna",	  	  
	  *			"kode_tarif": "AP",
	  *			"payor_id": "3",
	  *			"payor_cd": "JKN",
	  *         "cob_cd": "0001",          #ADD 5.3
	  *			"coder_nik": "123123123123"
	  *		}
	  *	}
	  * @return data response
	  * => Data Response
	  * {
	  *		"metadata": {
	  *			"code":"200",
	  *			"message":"OK"
	  *		}
	  *	}		
	 */		
	public function updateDataKlaim($data = array()) {
		$request = array(
			"metadata" => array(
				"method" => "set_claim_data",
				"nomor_sep" => $data["nomor_sep"]
			),
			"data" => $data
		);
		
		$data = json_encode($request);
		//file_put_contents("grouper.txt", $data);		
		$data = Crypto::encrypt($data, $this->config["key"]);
		
		return json_decode(Crypto::decrypt($this->sendRequest("POST", $data, "application/json"), $this->config["key"])); 
	}
	
	/**
	  * @method grouping
	  * @param $data array
	  * 3 & 4 Grouping
	  * => Data Request
	  * {
	  *		"metadata": {
	  *			"method": "grouper",
	  *			"stage": "1" / "2"
	  *		},
	  *		"data": {
	  *			"nomor_sep":"0301R00112140006067",
	  *			"special_cmg": "DD04" // stage 2
	  *		}
	  *	}
	  * @return data response
	  * => Data Response
	  * {
	  *		"metadata": {
	  *			"code":"200",
	  *			"message":"OK"
	  *		},
	  *		"response": {
	  *			"cbg": {
	  *				"code": "D-4-13-III",
	  *				"description": "GANGGUAN SEL . . ANEMIA SEL SICKLE (BERAT)",
	  *				"tariff": "7501700"
	  *			},
	  *			// untuk stage 2 
	  *			"special_cmg": [{
	  *				"code": "DD-04-II",
	  *				"description": "DEFERASIROX (IP)",
	  *				"tariff": 6216000,
	  *				"type": "Special Drug"	  
	  *			}]
	  *		},
	  *		"special_cmg_option": [
	  *			{
	  *				"code": "DD02",
	  *				"description": "Deferiprone (IP)",
	  *				"type": "Special Drug"
	  *			},
	  *			{
	  *				"code": "DD03",
	  *				"description": "Deferoksamin (IP)",
	  *				"type": "Special Drug"
	  *			},
	  *			{
	  *				"code": "DD04",
	  *				"description": "Deferasirox (IP)",
	  *				"type": "Special Drug"
	  *			}
	  *		]
	  *	}		
	 */		
	public function grouping($data = array()) {
		$stage = 1;
		$request = array(
			"metadata" => array(
				"method" => "grouper",
				"stage" => $stage
			),
			"data" => $data
		);
		
		if(isset($data["special_cmg"])) {
			$stage = 2;
			$request["metadata"]["stage"] = $stage;
		}
		
		$data = json_encode($request);
		$data = Crypto::encrypt($data, $this->config["key"]);
		
		return json_decode(Crypto::decrypt($this->sendRequest("POST", $data, "application/json"), $this->config["key"]));
	}
	
	/**
	  * @method finalKlaim
	  * @param $data array
	  * 5. Untuk finalisasi klaim
	  * => Data Request
	  * {
	  *		"metadata": {
	  *			"method": "claim_final"
	  *		},
	  *		"data": {
	  *			"nomor_sep":"0301R00112140006067",
	  *			"coder_nik":"NIK Pegawai"
	  *		}
	  *	}
	  * @return data response
	  * => Data Response
	  * {
	  *		"metadata": {
	  *			"code":"200",
	  *			"message":"OK"
	  *		}
	  *	}		
	 */		
	public function finalKlaim($data = array()) {
		$request = array(
			"metadata" => array(
				"method" => "claim_final"
			),
			"data" => $data
		);
		
		$data = json_encode($request);
		$data = Crypto::encrypt($data, $this->config["key"]);
		
		return json_decode(Crypto::decrypt($this->sendRequest("POST", $data, "application/json"), $this->config["key"])); 
	}
	
	/**
	  * @method reEditKlaim
	  * @param $data array
	  * 6. Untuk mengedit ulang klaim
	  * => Data Request
	  * {
	  *		"metadata": {
	  *			"method": "reedit_claim"
	  *		},
	  *		"data": {
	  *			"nomor_sep":"0301R00112140006067"
	  *		}
	  *	}
	  * @return data response
	  * => Data Response
	  * {
	  *		"metadata": {
	  *			"code":"200",
	  *			"message":"OK"
	  *		}
	  *	}		
	 */		
	public function reEditKlaim($data = array()) {
		$request = array(
			"metadata" => array(
				"method" => "reedit_claim"
			),
			"data" => $data
		);
		
		$data = json_encode($request);
		$data = Crypto::encrypt($data, $this->config["key"]);
		
		return json_decode(Crypto::decrypt($this->sendRequest("POST", $data, "application/json"), $this->config["key"])); 
	}
	
	/**
	  * @method kirimKlaim
	  * @param $data array
	  * 7. Untuk mengirim klaim ke DC per tanggal
	  * => Data Request
	  * {
	  *		"metadata": {
	  *			"method": "send_claim"
	  *		},
	  *		"data": {
	  *			"start_dt":"2016-01-07",
	  *			"stop_dt":"2016-01-07",
	  *			"jenis_rawat":"1"
	  *		}
	  *	}
	  * @return data response
	  * => Data Response
	  * {
	  *		"metadata": {
	  *			"code":"200",
	  *			"message":"OK"
	  *		},
	  *		"response": {
	  *			"data": [
	  *				{
	  *					"SEP": "0301R00112140006067",
	  *					"tgl_pulang": "2016-01-07 15:00:00",
	  *					"KEMENKES_DC_Status": "sent",
	  *					"BPJS_DC_Status": "unsent"
	  *				}
	  *			]
	  *		}		  
	  *	}		
	 */		
	public function kirimKlaim($data = array()) {
		$request = array(
			"metadata" => array(
				"method" => "send_claim"
			),
			"data" => $data
		);
		
		$data = json_encode($request);
		$data = Crypto::encrypt($data, $this->config["key"]);
		
		return json_decode(Crypto::decrypt($this->sendRequest("POST", $data, "application/json"), $this->config["key"])); 
	}
	
	/**
	  * @method kirimKlaimIndividual
	  * @param $data array
	  * 7. Untuk mengirim klaim ke DC berdasarkan nomor sep
	  * => Data Request
	  * {
	  *		"metadata": {
	  *			"method": "send_claim_individual"
	  *		},
	  *		"data": {
	  *			"nomor_sep":"0301R00112140006067"
	  *		}
	  *	}
	  * @return data response
	  * => Data Response
	  * {
	  *		"metadata": {
	  *			"code":"200",
	  *			"message":"OK"
	  *		},
	  *		"response": {
	  *			"data": [
	  *				{
	  *					"SEP": "0301R00112140006067",
	  *					"tgl_pulang": "2016-01-07 15:00:00",
	  *					"KEMENKES_DC_Status": "sent",
	  *					"BPJS_DC_Status": "unsent"
	  *				}
	  *			]
	  *		}		  
	  *	}		
	 */		
	public function kirimKlaimIndividual($data = array()) {
		$request = array(
			"metadata" => array(
				"method" => "send_claim_individual"
			),
			"data" => $data
		);
		
		$data = json_encode($request);
		$data = Crypto::encrypt($data, $this->config["key"]);
		
		return json_decode(Crypto::decrypt($this->sendRequest("POST", $data, "application/json"), $this->config["key"])); 
	}
	
	/**
	  * @method batalKlaim
	  * @param $data array
	  * Untuk membatalkan pengklaiman
	  * => Data Request
	  * {
	  *		"metadata": {
	  *			"method": "delete_claim"
	  *		},
	  *		"data": {
	  *			"nopen":"0301R00112140006067"
	  *			"nomor_sep":"0301R00112140006067"
	  *			"coder_nik":"1234567890123456"
	  *		}
	  *	}
	  * @return data response
	  * => Data Response
	  * {
	  *		"metadata": {
	  *			"code":"200",
	  *			"message":"OK"
	  *		}
	  *	}		
	 */		
	public function batalKlaim($data = []) {
		$nopen = $data["nopen"];
		$hasilGrouping = $this->hasilGrouping->load(["NOPEN" => $nopen]);
		
		unset($data["nopen"]);
		unset($data["tipe"]);
		
		if(count($hasilGrouping) > 0) $this->hasilGrouping->hapus(["NOPEN" => $nopen]);
		
		$request = [
			"metadata" => [
				"method" => "delete_claim"
			],
			"data" => $data
		];		
		
		$data = json_encode($request);
		$data = Crypto::encrypt($data, $this->config["key"]);
		
		$result = json_decode(Crypto::decrypt($this->sendRequest("POST", $data, "application/json"), $this->config["key"])); 		
		return $result;
	}
	
	/**
	  * @method grouper 
	  * @params $data array
	  * => Data Request
	  * {
	  *		"norm": 123456,
	  *		"nm_pasien": "Nama Pasien",
	  *		"jns_kelamin": "Jenis Kelamin",	  
	  *		"tgl_lahir": "Tanggal Lahir",
	  *		"jns_pbyrn": "Jenis Pembayaran",
	  *		"no_peserta": "No. kartu Peserta",
	  *		"no_sep": "No. SEP",
	  *		"jns_perawatan": "Jenis Perawatan",
	  *		"kls_perawatan": "Kelas Perawatan",
	  *		"tgl_masuk": "Tanggal Masuk",
	  *		"tgl_keluar": "Tanggal Keluar",

	  * #NEW 5.8.x
	  *		"cara_masuk": "Cara Masuk",

	  *		"cara_keluar": "Cara Keluar / Pulang",
	  *		"dpjp": "Dokter Penanggungjawab",
	  *		"berat_lahir": "Berat Bayi Lahir",
	  *		"tarif_rs": "Tarif Rumah Sakit
	  *	NEW IN INACBG 5.2
	  *		"prosedur_non_bedah": 0,	
	  *		"prosedur_bedah": 0,		
	  *		"konsultasi": 0,
	  *		"tenaga_ahli": 0,	
	  *		"keperawatan": 0,		
	  *		"penunjang": 0,			
	  *		"radiologi": 0,
	  *		"laboratorium": 0,	
	  *		"pelayanan_darah": 0,	
	  *		"rehabilitasi": 0,		
	  *		"kamar": 0,
	  *		"rawat_intensif": 0,	
	  *		"obat": 0,
	  *     "obat_kronis": 0,
	  *     "obat_kemoterapi": 0,				
	  *		"alkes": 0, 
	  *		"bmhp": 0,			
	  *		"sewa_alat": 0,
	  *		"tarif_poli_eks": "Tarif Poli Eksekutif",
	  *		"srt_rujukan": "Ada Surat Rujukan",
	  *		"bhp": "Bahan Habis Pakai",
	  *		"severity3": "Severity3",
	  *		"diag1": "Diagnosa ke 1", // sampai ke
	  *		"diag30": "Diagnosa ke 30",
	  *		"proc1": "Procedure ke 1", // sampai ke
	  *		"proc30": "Procedure ke 30",

	  *		#NEW "INA Grouper",
	  *		"ina_diag1": "Ina Grouper Diagnosa ke 1", // sampai ke
	  *		"ina_diag30": "Ina Grouper Diagnosa ke 30",
	  *		"ina_proc1": "Ina Grouper Procedure ke 1", // sampai ke
	  *		"ina_proc30": "Ina Grouper Procedure ke 30",

	  *		#NEW 2020-04-20 "Pasien Covid-19",
	  *		"covid": [
	  *			"pemulasaraan_jenazah": "1",
 	  *			"kantong_jenazah": "1",
  	  *			"peti_jenazah": "1",
  	  *			"plastik_erat": "1",
  	  *			"desinfektan_jenazah": "1",
  	  *			"mobil_jenazah": "0",
  	  *			"desinfektan_mobil_jenazah": "0",
	  *			"covid19_status_cd": "1",	  	
  	  *			"nomor_kartu_t": "nik",
  	  *			"episodes": "1;12#2;3#6;5",
	  *			"covid19_cc_ind": "1"
	  * #NEW 2020-08-13
	  *			"covid19_rs_darurat_ind": "1",
	  *			"covid19_co_insidense_ind": "1",
	  *			"covid19_no_sep": "", 
	  *			"covid19_penunjang_pengurang": { //0 = dilakukan, 1 = tidak dilakukan
	  *				"lab_asam_laktat": "1",
	  *				"lab_procalcitonin": "1",
	  *				"lab_crp": "1",
	  *				"lab_kultur": "1",
	  *				"lab_d_dimer": "1",
	  *				"lab_pt": "1",
	  *				"lab_aptt": "1",
	  *				"lab_waktu_pendarahan": "1",
	  *				"lab_anti_hiv": "1",
	  *				"lab_analisa_gas": "1",
	  *				"lab_albumin": "1",
	  *				"rad_thorax_ap_pa": "1"
	  *			},
	  *     ],

	  * #NEW 2021-07-12
	  *		"terapi_konvalesen": "1000000",
	  *		"akses_naat": "C",
      *		"isoman_ind": "0",
	  *		"bayi_lahir_status_cd": 1,

	  * #NEW 5.8.x
	  *		"dializer_single_use": "0",
	  *		"kantong_darah": 1,
	  *		"apgar": {
	  *			"menit_1": {
	  *				"appearance": 1,
	  *				"pulse": 2,
	  *				"grimace": 1,
	  *				"activity": 1,
	  *				"respiration": 1
	  *			},
	  *			"menit_5": {
	  *				"appearance": 2,
	  *				"pulse": 2,
	  *				"grimace": 2,
	  *				"activity": 2,
	  *				"respiration": 2
	  *			}
	  *		},
	  *		"persalinan": {
	  *			"usia_kehamilan": "22",
	  *			"gravida": "2",
	  *			"partus": "4",
	  *			"abortus": "2",
	  *			"onset_kontraksi": "induksi",
	  *			"delivery": [
	  *				{
	  *					"delivery_sequence": "1",
	  *					"delivery_method": "vaginal",
	  *					"delivery_dttm": "2023-01-21 17:01:33",
	  *					"letak_janin": "kepala",
	  *					"kondisi": "livebirth",
	  *					"use_manual": "1",
	  *					"use_forcep": "0",
	  *					"use_vacuum": "1",
	  *					"shk_spesimen_ambil": "tidak", // ya | tidak
	  *					"shk_lokasi": "", // tumit | vena
	  *					"shk_alasan": "", // tidak-dapat | akses-sulit
	  *					"shk_spesimen_dttm": "", // tanggal pengambilan spesimen iso dttm
	  *				},
	  *				{
	  *				"delivery_sequence": "2",
	  *					"delivery_method": "vaginal",
	  *					"delivery_dttm": "2023-01-21 17:03:49",
	  *					"letak_janin": "lintang",
	  *					"kondisi": "livebirth",
	  *					"use_manual": "1",
	  *					"use_forcep": "0",
	  *					"use_vacuum": "0",
	  *					"shk_spesimen_ambil": "tidak", // ya | tidak
	  *					"shk_lokasi": "", // tumit | vena
	  *					"shk_alasan": "", // tidak-dapat | akses-sulit
	  *					"shk_spesimen_dttm": "", // tanggal pengambilan spesimen iso dttm
	  *				}
	  *			]
	  *		},

	  *		"adl_sub_acute": "ADL Sub Akut",
	  *		"adl_chronic": "ADL Chronic",
	  *		"icu_indikator": "ICU Indikator",
	  *		"icu_los": "ICU LOS",

	  *		"upgrade_class_ind": "1",
	  *		"upgrade_class_class": "vip",
	  *		"upgrade_class_los": "5",
	  *		"add_payment_pct": "tambahan biaya khusus naik kelas VIP",

	  * #NEW 5.8.x
	  *		"upgrade_class_payor": "peserta",
	  *		"sistole": "120",
	  *		"diastole": "70",

	  *		"ventilator_hour": "Ventilator Hour",
	  * #NEW 5.8.x
	  *		"ventilator": {,
	  *			"use_ind": "1",
	  *			"start_dttm": "2023-01-26 12:55:00",
	  *			"stop_dttm": "2023-01-26 17:50:00",
	  *		},
	  *		"spec_proc": "Special Procedure",
	  *		"spec_dr": "Special Drug",
	  *		"spec_inv": "Special Investigation",
	  *		"spec_prosth": "Special Prosthesis",
	  *     "cob_cd": "0001",
	  *		"nopen": "No. Pendaftaran",
	  *		"user": "Pengguna ID",
	  *		"user_nik": "NIK Pengguna",	  
	  *		"status": "0 = false (Belum Final) | 1 = true (Final)",
	  *		"kirim": "0 = false (Belum Kirim) | 1 = true (Sudah Kirim)",
	  *		"type" : "tipe inacbg"
	  *	} 
	  * @return
	  */
	
	function grouper($data = []) {
		$data = is_array($data) ? $data : (array) $data;
		$response = [];
		$hasilGrouping = $this->hasilGrouping->load(["NOPEN" => $data["nopen"]]);
		
		$result = [
			"metaData" => [
				"code" => "500",
				"message" => "Gagal Grouping",
			],
			"response" => [
				"Grouper" => [
					"Drug" => [
						"Deskripsi" => null,
						"Kode" => "None",
						"Tarif" => 0
					],	
					"Investigation" => [
						"Deskripsi" => null,
						"Kode" => "None",
						"Tarif" => 0	
					],	
					"Procedure" => [
						"Deskripsi" => null,
						"Kode" => "None",
						"Tarif" => 0	
					],	
					"Prosthesis" => [
						"Deskripsi" => null,
						"Kode" => "None",
						"Tarif" => 0
					],	
					"SubAcute" => [
						"Deskripsi" => null,
						"Kode" => "None",
						"Tarif" => 0
					],
					"Chronic" => [
						"Deskripsi" => null,
						"Kode" => "None",
						"Tarif" => 0
					],
					"deskripsi" => "",
					"kodeInacbg" => "",
					"noSep" => $data["no_sep"],
					"tarifGruper" => 0,
					"totalTarif" => 0,
					"tarifKelas1" => 0,
					"tarifKelas2" => 0,
					"tarifKelas3" => 0,
					"ina" => [
						"mdcNumber" => "",
						"mdcDescription" => "",
						"drgCode" => "",
						"drgDescription" => ""
					],
					"covid19" => [
						"topUpRawatGross" => 0,
						"topUpRawatFactor" => 0,
						"topUpRawat" => 0,
						"topUpJenazah" => 0,
						"deskripsi" => ""
					]
				],
				"kirimKlaim" => [
					"DC_KEMKES" => 0,
					"DC_BPJS" => 0
				],
				"finalKlaim" => 0
			]
		];		
		/* buat klaim baru */
		if(count($hasilGrouping) == 0) {
			// Jika bukan pasien JKN maka generate nomor klaim
			if($data["jns_pbyrn"] != 3 && ($data["no_sep"] == "" || $data["no_sep"] == null)) {
				$resNomor = $this->generateNomorKlaim();
				$response["generateNomorKlaim"] = $resNomor;

				if($resNomor->metadata->code != 200) {
					$result["metaData"]["code"] = $resNomor->metadata->code;
					$error = isset($resNomor->metadata->error_no) ? $resNomor->metadata->error_no." - " : "";
					$result["metaData"]["message"] = $error.$resNomor->metadata->message;
				} else {
					$data["no_sep"] = $resNomor->response->claim_number;
				}
			}

			$klaimBaru = $this->klaimBaru([
				"nomor_kartu" => $data["no_peserta"],
				"nomor_sep" => $data["no_sep"],
				"nomor_rm" => $data["norm"],
				"nama_pasien" => $data["nm_pasien"],
				"tgl_lahir" => $data["tgl_lahir"],
				"gender" => $data["jns_kelamin"]
			]);
			
			$response["klaimBaru"] = $klaimBaru;
		} else {
			// Jika bukan pasien JKN maka ambil no sep di table
			if($data["jns_pbyrn"] != 3) $data["no_sep"] = $hasilGrouping[0]["NOSEP"];
			
			/* jika sebelumnya final maka reFinalKlaim */
			if($hasilGrouping[0]["STATUS"] == 1) {
				$reFinalKlaim = $this->reEditKlaim([
					"nomor_sep" => $data["no_sep"]
				]);
				$response["reFinalKlaim"] = $reFinalKlaim;
			}			
			
			/* update data pasien */
			$updateDataPasien = $this->updateDataPasien([
				"nomor_kartu" => $data["no_peserta"],
				"nomor_rm" => $data["norm"],
				"nama_pasien" => $data["nm_pasien"],
				"tgl_lahir" => $data["tgl_lahir"],
				"gender" => $data["jns_kelamin"]
			]);
			
			$response["updateDataPasien"] = $updateDataPasien;
		}
				
		//file_put_contents("logs/grouper_post_data.txt", json_encode($data));
		$diags = [];
		$notIsSetCount = 0;
		for($i = 1; $i <= 30; $i++) {
			$diag = "diag".$i;
			if(isset($data[$diag])) $diags[] = $data[$diag];
			else $notIsSetCount++;
			
			if($notIsSetCount > 1) break;
		}
		$diags = implode("#", $diags);
		
		$procs = [];
		$notIsSetCount = 0;
		for($i = 1; $i <= 30; $i++) {
			$proc = "proc".$i;
			if(isset($data[$proc])) $procs[] = $data[$proc];
			else $notIsSetCount++;
			
			if($notIsSetCount > 1) break;
		}
		$procs = implode("#", $procs);

		// Ina Grouper Diagnosa & Procedure
		$ina_diags = [];
		$notIsSetCount = 0;
		for($i = 1; $i <= 30; $i++) {
			$ina_diag = "ina_diag".$i;
			if(isset($data[$ina_diag])) $ina_diags[] = $data[$ina_diag];
			else $notIsSetCount++;
			
			if($notIsSetCount > 1) break;
		}
		$ina_diags = implode("#", $ina_diags);
		
		$ina_procs = [];
		$notIsSetCount = 0;
		for($i = 1; $i <= 30; $i++) {
			$ina_proc = "ina_proc".$i;
			if(isset($data[$ina_proc])) $ina_procs[] = $data[$ina_proc];
			else $notIsSetCount++;
			
			if($notIsSetCount > 1) break;
		}
		$ina_procs = implode("#", $ina_procs);
		
		$tarifRs = $data["tarif_rs"];
		$dataUpdateKlaim = [
			"nomor_sep" => $data["no_sep"],
			"nomor_kartu" => $data["no_peserta"],
			"tgl_masuk" => $data["tgl_masuk"],
			"tgl_pulang" => $data["tgl_keluar"],
			"jenis_rawat" => $data["jns_perawatan"],
			"kelas_rawat" => $data["kls_perawatan"],

			"cara_masuk" => $data["cara_masuk"],
			
			"adl_sub_acute" => $data["adl_sub_acute"],
			"adl_chronic" => $data["adl_chronic"],
			"icu_indikator" => isset($data["icu_indikator"]) ? $data["icu_indikator"] : 0,
			"icu_los" => isset($data["icu_los"]) ? isset($data["icu_los"]) : 0,
			"ventilator_hour" => isset($data["ventilator_hour"]) ? $data["ventilator_hour"] : 0,
			"ventilator" => [
				"use_ind" => isset($data["ventilator"]["use_ind"]) ? $data["ventilator"]["use_ind"] : 0,
				"start_dttm" => isset($data["ventilator"]["start_dttm"]) ? $data["ventilator"]["start_dttm"] : "",
				"stop_dttm" => isset($data["ventilator"]["stop_dttm"]) ? $data["ventilator"]["stop_dttm"] : "",
			],
			"upgrade_class_ind" => isset($data["upgrade_class_ind"]) ? $data["upgrade_class_ind"] : 0,
			"upgrade_class_class" => isset($data["upgrade_class_class"]) ? $data["upgrade_class_class"] : "",
			"upgrade_class_los" => isset($data["upgrade_class_los"]) ? $data["upgrade_class_los"] : 0,
			"add_payment_pct" => isset($data["add_payment_pct"]) ? $data["add_payment_pct"] : 0,
			"upgrade_class_payor" => isset($data["upgrade_class_payor"]) ? $data["upgrade_class_payor"] : "",
			"sistole" => isset($data["sistole"]) ? $data["sistole"] : 0,
			"diastole" => isset($data["diastole"]) ? $data["diastole"] : 0,

			"birth_weight" => $data["berat_lahir"],
			"discharge_status" => $data["cara_keluar"],
			"diagnosa" => $diags,
			"procedure" => $procs == '' ? '#' : $procs,

			// Ina Grouper
			"diagnosa_inagrouper" => $ina_diags,
			"procedure_inagrouper" => $ina_procs == '' ? '#' : $ina_procs,
			
			"tarif_rs" => $data["tarif_rs"],
			"tarif_poli_eks" => $data["tarif_poli_eks"],
			"nama_dokter" => $data["dpjp"],
			
			"kode_tarif" => $this->config["kode_tarif"],
			"payor_id" => isset($data["jns_pbyrn"]) ? $data["jns_pbyrn"] : 3,
			"payor_cd" => isset($data["jns_pbyrn"]) ? ($data["jns_pbyrn"] == 3 ? "JKN" : $data["jns_pbyrn"]) : "JKN",		   
			"coder_nik" => $data["user_nik"]
		];

		// Pasien Covid
		if($data["jns_pbyrn"] == 71) {
			if(count($data["covid"]) > 0) {
				if($data["cara_keluar"] == 4) {
					$dataUpdateKlaim["pemulasaraan_jenazah"] = $data["covid"]["pemulasaraan_jenazah"];
					$dataUpdateKlaim["kantong_jenazah"] = $data["covid"]["kantong_jenazah"];
					$dataUpdateKlaim["peti_jenazah"] = $data["covid"]["peti_jenazah"];
					$dataUpdateKlaim["plastik_erat"] = $data["covid"]["plastik_erat"];
					$dataUpdateKlaim["desinfektan_jenazah"] = $data["covid"]["desinfektan_jenazah"];
					$dataUpdateKlaim["mobil_jenazah"] = $data["covid"]["mobil_jenazah"];
					$dataUpdateKlaim["desinfektan_mobil_jenazah"] = $data["covid"]["desinfektan_mobil_jenazah"];
				}
				$dataUpdateKlaim["covid19_status_cd"] = $data["covid"]["covid19_status_cd"];
				$dataUpdateKlaim["nomor_kartu_t"] = $data["covid"]["nomor_kartu_t"];
				$dataUpdateKlaim["covid19_status_cd"] = $data["covid"]["covid19_status_cd"];
				$dataUpdateKlaim["episodes"] = isset($data["covid"]["episodes"]) ? $data["covid"]["episodes"] : "#";
				$dataUpdateKlaim["covid19_cc_ind"] = $data["covid"]["covid19_cc_ind"];
				$dataUpdateKlaim["covid19_rs_darurat_ind"] = $data["covid"]["covid19_rs_darurat_ind"];
				$dataUpdateKlaim["covid19_co_insidense_ind"] = $data["covid"]["covid19_co_insidense_ind"];
				$dataUpdateKlaim["covid19_no_sep"] = isset($data["covid"]["covid19_no_sep"]) ? $data["covid"]["covid19_no_sep"] : "";
				$dataUpdateKlaim["covid19_penunjang_pengurang"] = $data["covid"]["covid19_penunjang_pengurang"];				
			}
		} else {
			if(isset($data["covid"])) {
				$dataUpdateKlaim["covid19_co_insidense_ind"] = $data["covid"]["covid19_co_insidense_ind"];
				$dataUpdateKlaim["covid19_no_sep"] = isset($data["covid"]["covid19_no_sep"]) ? $data["covid"]["covid19_no_sep"] : "";
			}
		}
		
		// Jika ada distribusi tarif maka ganti tarif menjadi distribusi tarif inacbg 5.2
		if($this->config["version"]["minor"] >= 2) {
		    if(isset($data["cob_cd"])) $dataUpdateKlaim["cob_cd"] = $data["cob_cd"];
			$dataUpdateKlaim["tarif_rs"] = [
				"prosedur_non_bedah" => isset($data["prosedur_non_bedah"]) ?  $data["prosedur_non_bedah"] : 0,
				"prosedur_bedah" => isset($data["prosedur_bedah"]) ?  $data["prosedur_bedah"] : 0,
				"konsultasi" => isset($data["konsultasi"]) ?  $data["konsultasi"] : 0,
				"tenaga_ahli" => isset($data["tenaga_ahli"]) ?  $data["tenaga_ahli"] : 0,
				"keperawatan" => isset($data["keperawatan"]) ?  $data["keperawatan"] : 0,
				"penunjang" => isset($data["penunjang"]) ?  $data["penunjang"] : 0,
				"radiologi" => isset($data["radiologi"]) ?  $data["radiologi"] : 0,
				"laboratorium" => isset($data["laboratorium"]) ?  $data["laboratorium"] : 0,
				"pelayanan_darah" => isset($data["pelayanan_darah"]) ?  $data["pelayanan_darah"] : 0,
				"rehabilitasi" => isset($data["rehabilitasi"]) ?  $data["rehabilitasi"] : 0,
				"kamar" => isset($data["kamar"]) ?  $data["kamar"] : 0,
				"rawat_intensif" => isset($data["rawat_intensif"]) ?  $data["rawat_intensif"] : 0,
				"obat" => isset($data["obat"]) ?  $data["obat"] : 0,
			    "obat_kronis" => isset($data["obat_kronis"]) ?  $data["obat_kronis"] : 0,
			    "obat_kemoterapi" => isset($data["obat_kemoterapi"]) ?  $data["obat_kemoterapi"] : 0,
				"alkes" => isset($data["alkes"]) ?  $data["alkes"] : 0,
				"bmhp" => isset($data["bmhp"]) ?  $data["bmhp"] : 0,
				"sewa_alat" => isset($data["sewa_alat"]) ?  $data["sewa_alat"] : 0
			];			
		}
		
		if(isset($data["terapi_konvalesen"]) && $data["jns_perawatan"] == 1) $dataUpdateKlaim["terapi_konvalesen"] = $data["terapi_konvalesen"];
		if(isset($data["akses_naat"])) $dataUpdateKlaim["akses_naat"] = $data["akses_naat"];
		if(isset($data["isoman_ind"]) && $data["jns_pbyrn"] == 71) $dataUpdateKlaim["isoman_ind"] = $data["isoman_ind"];
		if($data["jns_pbyrn"] == 73) $dataUpdateKlaim["bayi_lahir_status_cd"] = $data["bayi_lahir_status_cd"];
		
		if(isset($data["dializer_single_use"])) $dataUpdateKlaim["dializer_single_use"] = $data["dializer_single_use"];
		if(isset($data["kantong_darah"])) $dataUpdateKlaim["kantong_darah"] = $data["kantong_darah"];
		if(isset($data["apgar"])) $dataUpdateKlaim["apgar"] = $data["apgar"];
		if(isset($data["persalinan"])) $dataUpdateKlaim["persalinan"] = $data["persalinan"];

		file_put_contents("logs/grouper_post_data.txt", json_encode($dataUpdateKlaim));
		/* step 3 update klaim */
		$updateDataKlaim = $this->updateDataKlaim($dataUpdateKlaim);
		//file_put_contents("updateDataKlaim.txt", json_encode($updateDataKlaim));
		$response["updateDataKlaim"] = $updateDataKlaim;
		if($response["updateDataKlaim"]->metadata->code != 200) {
			$result["metaData"]["code"] = $response["updateDataKlaim"]->metadata->code;
			$result["metaData"]["message"] = $response["updateDataKlaim"]->metadata->message;
			
			file_put_contents("logs/grouper.txt", json_encode($response));
			return json_decode(json_encode($result));
		}
				
		/* grouping stage 1 */
		$dataGrouping = [
			"nomor_sep" => $data["no_sep"]
		];
		$grouping = $this->grouping($dataGrouping);
		$response["grouping_stage_1"] = $grouping;
		
		$scmgs = [];			
		if($response["grouping_stage_1"]->metadata->code == 200) {
			$cmgs = isset($response["grouping_stage_1"]->special_cmg_option) ? (count($response["grouping_stage_1"]->special_cmg_option) > 0 ? $response["grouping_stage_1"]->special_cmg_option : false) : false;
			$specpr = isset($data["spec_proc"]) ? $data["spec_proc"] : "";
			$specpros = isset($data["spec_prosth"]) ? $data["spec_prosth"] : "";
			$specdr = isset($data["spec_dr"]) ? $data["spec_dr"] : "";
			$data["spec_dr"] = null;
			if($cmgs) {
				foreach($cmgs as $cmg) {
					//if($cmg->type == "Special Procedure") $data["spec_proc"] = $cmg->code;
					//if($cmg->type == "Special Prosthesis") $data["spec_prosth"] = $cmg->code;
					if($cmg->type == "Special Investigation") $data["spec_inv"] = $cmg->code;
					/*if($cmg->type == "Special Drug" && $specdr == '') {
						$data["spec_dr"] = $cmg->code;
						$scmgs[] = $cmg->code;
						continue;
					}*/
					//if($cmg->type == "Special SubAcute") $data["adl_sub_acute"] = $cmg->code;
					//if($cmg->type == "Special Chronic") $data["adl_chronic"] = $cmg->code;
					if($cmg->type != "Special Drug") {
						//if($cmg->type == "Special Procedure" && $specpr == "") $scmgs[] = $cmg->code;
						//if($cmg->type == "Special Prosthesis" && $specpros == "") $scmgs[] = $cmg->code;
						if($cmg->type != "Special Procedure" || $cmg->type != "Special Prosthesis") $scmgs[] = $cmg->code;
					}
				}													
			}
			
			if($specpr != '') $scmgs[] = $specpr;
			if($specpros != '') $scmgs[] = $specpros;
			if($specdr != '') $scmgs[] = $specdr;
			
			if(count($scmgs) > 0) {
				$dataGrouping["special_cmg"] = implode("#", $scmgs);
				
				/* grouping stage 2 */
				$grouping = $this->grouping($dataGrouping);
				$response["grouping_stage_2"] = $grouping;
			}
		}			
		
		if($data["status"]) {				
			/* final grouping */
			$finalKlaim = $this->finalKlaim([
				"nomor_sep" => $data["no_sep"],
				"coder_nik" => $data["user_nik"]
			]);
			$response["finalKlaim"] = $finalKlaim;			
		}
		
		/* step 7 kirim klaim */
		if($data["kirim"]) {
			$kirimKlaim = $this->kirimKlaimIndividual([
				"nomor_sep" => $data["no_sep"]
			]);
			$response["kirimKlaim"] = $kirimKlaim;			
		}			
		
		$dcKEMKES = $dcBPJS = 0;
		
		if(isset($grouping)) {
		    file_put_contents("logs/grouper_result_01.txt", json_encode((array) $grouping));
			$result["metaData"]["code"] = $grouping->metadata->code;
			$result["metaData"]["message"] = $grouping->metadata->message;
			
			$total = 0;
			
			$cbg = isset($grouping->response->cbg) ? $grouping->response->cbg : null;
			$result["response"]["Grouper"]["kodeInacbg"] = isset($cbg->code) ? $cbg->code : "";
			$result["response"]["Grouper"]["deskripsi"] = isset($cbg->description) ? $cbg->description : "";
			$total = $result["response"]["Grouper"]["tarifGruper"] = isset($cbg->base_tariff) ? $cbg->base_tariff : 0;
			if(isset($data["dializer_single_use"])) {
				if($data["dializer_single_use"] == "0") {
					$tbefore = $total;
					$total = $result["response"]["Grouper"]["tarifGruper"] = isset($cbg->tariff) ? $cbg->tariff : $tbefore;
				}
			}
			if($cbg) {
				$founds = $this->refInacbg->load(["JENIS" => 1, "KODE" => $cbg->code, "VERSION" => 5]);
				if(count($founds) == 0) {
					$this->refInacbg->simpanData([
						"JENIS" => 1,
						"KODE" => $cbg->code,
						"DESKRIPSI" => $cbg->description,
						"VERSION" => 5
					], true, false);
				}
			}
			
			if(isset($grouping->response->sub_acute)) {
				$sa = $grouping->response->sub_acute;
				$result["response"]["Grouper"]["SubAcute"]["Kode"] = $sa->code;
				$result["response"]["Grouper"]["SubAcute"]["Deskripsi"] = $sa->description;
				$result["response"]["Grouper"]["SubAcute"]["Tarif"] = $sa->tariff;
			}
			
			if(isset($grouping->response->chronic)) {
				$chr = $grouping->response->chronic;
				$result["response"]["Grouper"]["Chronic"]["Kode"] = $chr->code;
				$result["response"]["Grouper"]["Chronic"]["Deskripsi"] = $chr->description;
				$result["response"]["Grouper"]["Chronic"]["Tarif"] = $chr->tariff;
			}
			
			if(isset($grouping->tarif_alt)) {
				foreach($grouping->tarif_alt as $trf) {
					if($trf->kelas == "kelas_1") $result["response"]["Grouper"]["tarifKelas1"] = $trf->tarif_inacbg ? $trf->tarif_inacbg : 0;
					if($trf->kelas == "kelas_2") $result["response"]["Grouper"]["tarifKelas2"] = $trf->tarif_inacbg ? $trf->tarif_inacbg : 0;
					if($trf->kelas == "kelas_3") $result["response"]["Grouper"]["tarifKelas3"] = $trf->tarif_inacbg ? $trf->tarif_inacbg : 0;
				}
			}
							
			if(isset($grouping->response->special_cmg)) {
				foreach($grouping->response->special_cmg as $cmg) {
					if($cmg->type == "Special Drug") {
						$result["response"]["Grouper"]["Drug"]["Kode"] = $cmg->code;
						$result["response"]["Grouper"]["Drug"]["Deskripsi"] = $cmg->description;
						$result["response"]["Grouper"]["Drug"]["Tarif"] = $cmg->tariff;
					} 
					if($cmg->type == "Special Prosthesis") {
						$result["response"]["Grouper"]["Prosthesis"]["Kode"] = $cmg->code;
						$result["response"]["Grouper"]["Prosthesis"]["Deskripsi"] = $cmg->description;
						$result["response"]["Grouper"]["Prosthesis"]["Tarif"] = $cmg->tariff;
					} 
					if($cmg->type == "Special Procedure") {
						$result["response"]["Grouper"]["Procedure"]["Kode"] = $cmg->code;
						$result["response"]["Grouper"]["Procedure"]["Deskripsi"] = $cmg->description;
						$result["response"]["Grouper"]["Procedure"]["Tarif"] = $cmg->tariff;
					} 
					if($cmg->type == "Special Investigation") {
						$result["response"]["Grouper"]["Investigation"]["Kode"] = $cmg->code;
						$result["response"]["Grouper"]["Investigation"]["Deskripsi"] = $cmg->description;
						$result["response"]["Grouper"]["Investigation"]["Tarif"] = $cmg->tariff;
					}
				}
			}

			if(isset($grouping->response->covid19_data)) {
				$covid = $grouping->response->covid19_data;
				$result["response"]["Grouper"]["covid19"]["topUpRawatGross"] = $covid->top_up_rawat_gross;
				$result["response"]["Grouper"]["covid19"]["topUpRawatFactor"] = $covid->top_up_rawat_factor;
				$result["response"]["Grouper"]["covid19"]["topUpRawat"] = $covid->top_up_rawat;
				$result["response"]["Grouper"]["covid19"]["topUpJenazah"] = $covid->top_up_jenazah;
				$desk = $covid->covid19_status_nm." Covid-19";
				$los = 0;
				foreach($covid->episodes as $epi) {
					$los += $epi->los;
				}
				$ind = ($covid->cc_ind == 0 ? " Tanpa " : " dengan ")."Komorbid / Komplikasi";
				$desk .= $ind." ($los Hari)";
				$result["response"]["Grouper"]["covid19"]["deskripsi"] = $desk;
			}

			if(isset($grouping->response_inagrouper)) {
				$ina = $grouping->response_inagrouper;
				$result["response"]["Grouper"]["ina"]["mdcNumber"] = $ina->mdc_number;
				$result["response"]["Grouper"]["ina"]["mdcDescription"] = $ina->mdc_description;
				$result["response"]["Grouper"]["ina"]["drgCode"] = $ina->drg_code;
				$result["response"]["Grouper"]["ina"]["drgDescription"] = $ina->drg_description;
			}
		}

		if(isset($response["finalKlaim"])) {
			if($response["finalKlaim"]->metadata->code != 200) {
				$data["status"] = 0;
				$result["metaData"]["code"] = $response["finalKlaim"]->metadata->code;
				$result["metaData"]["message"] = $response["finalKlaim"]->metadata->message;
			}
			$result["response"]["finalKlaim"] = $data["status"];
		}
		
		if(isset($response["kirimKlaim"])) {
			$list = [];
			if($response["kirimKlaim"]->metadata->code == 200) {
				$list = $response["kirimKlaim"]->response->data;
				if($list) {
					foreach($list as $l) {
						$dcKEMKES = $l->kemkes_dc_status == 'sent' ? 1 : 0;
						$dcBPJS = $l->bpjs_dc_status == 'sent' ? 1 : 0;
						$result["response"]["kirimKlaim"]["DC_KEMKES"] = $dcKEMKES;
						$result["response"]["kirimKlaim"]["DC_BPJS"] = $dcBPJS;
					}
				}				
			} else {
				$data["kirim"] = 0;
				$result["metaData"]["code"] = $response["kirimKlaim"]->metadata->code;
				$result["metaData"]["message"] = $response["kirimKlaim"]->metadata->message;
			}
		}
				
		$result = json_decode(json_encode($result));
		file_put_contents("logs/grouper.txt", json_encode($response));
		file_put_contents("logs/grouper_result.txt", json_encode($result));
		$grouper = $result->response->Grouper;
		if($result->metaData->code == 200) {
			$tot = $grouper->Procedure->Tarif + $grouper->Drug->Tarif + $grouper->Investigation->Tarif + $grouper->Prosthesis->Tarif + $grouper->SubAcute->Tarif + $grouper->Chronic->Tarif;
			$grouper->totalTarif = $grouper->tarifGruper + ($tot ? $tot : 0);
		}
		$this->hasilGrouping->simpanData([
			'NOPEN' => $data['nopen']
			, 'NOSEP' => $data['no_sep']
			, 'CODECBG' => $grouper->kodeInacbg
			, 'TARIFCBG' => $grouper->tarifGruper
			, 'TARIFSP' => $grouper->Procedure->Tarif
			, 'TARIFSR' => $grouper->Prosthesis->Tarif
			, 'TARIFSI' => $grouper->Investigation->Tarif
			, 'TARIFSD' => $grouper->Drug->Tarif
			, 'TARIFSA' => $grouper->SubAcute->Tarif
			, 'TARIFSC' => $grouper->Chronic->Tarif
			, 'TARIFKLS1' => $grouper->tarifKelas1
			, 'TARIFKLS2' => $grouper->tarifKelas2
			, 'TARIFKLS3' => $grouper->tarifKelas3
			, 'TOTALTARIF' => $grouper->totalTarif
			, 'TARIFRS' => $tarifRs
			, 'UNUSR' => $grouper->Prosthesis->Kode
			, 'UNUSI' => $grouper->Investigation->Kode
			, 'UNUSP' => $grouper->Procedure->Kode
			, 'UNUSD' => $grouper->Drug->Kode
			, 'UNUSA' => $grouper->SubAcute->Kode
			, 'UNUSC' => $grouper->Chronic->Kode
			, 'TANGGAL' => new \Laminas\Db\Sql\Expression('NOW()')
			, 'USER' => $data["user"]
			, 'STATUS' => ($data['status'] == 1 ? "1" : "0")
			, 'TIPE' => $data["tipe"]
			, 'DC_KEMKES' => $dcKEMKES
			, 'DC_BPJS' => $dcBPJS
			, "POST_DATA" => json_encode($dataUpdateKlaim)
			, 'RESPONSE' => json_encode($response)
			, "INA_GROUPER_MDC_NUMBER" => $grouper->ina->mdcNumber
			, "INA_GROUPER_MDC_DESCRIPTION" => $grouper->ina->mdcDescription
			, "INA_GROUPER_DRG_CODE" => $grouper->ina->drgCode
			, "INA_GROUPER_DRG_DESCRIPTION" => $grouper->ina->drgDescription
			, "TOP_UP_RAWAT_GROSS" => $grouper->covid19->topUpRawatGross
			, "TOP_UP_RAWAT_FACTOR" => $grouper->covid19->topUpRawatFactor
			, "TOP_UP_RAWAT" => $grouper->covid19->topUpRawat
			, "TOP_UP_JENAZAH" => $grouper->covid19->topUpJenazah
			, "COVID_19_DESCRIPTION" => $grouper->covid19->deskripsi
		], count($hasilGrouping) == 0, false);
		
		return $result;
	}

	/**
	  * @method Diagnosa INA Grouper
	  * @param $data array
	  * 10. Pencarian diagnosa INA Grouper
	  * => Data Request
	  * {
	  *		"metadata": {
	  *			"method": "search_diagnosis_inagrouper"
	  *		},
	  *		"data": {
	  *			"keyword":"A00"
	  *		}
	  *	}
	  * @return data response
	  * => Data Response
	  * {
	  *		"metadata": {
	  *			"code":"200",
	  *			"message":"Ok"
	  *		},
	  *		"response": {
	  *			"count": 4,	  
	  *			"data": [
	  *				{
	  *					"description": "Cholera",
	  *					"code": "A00",
	  *					"validcode": "0",
	  *					"accpdx": "Y",
	  *					"code_asterisk": "A00"
	  *				}
	  *			...
	  *			]
	  *		}		  
	  *	}		
	 */		
	public function diagnosaInaGrouper($data = []) {
		$request = [
			"metadata" => [
				"method" => "search_diagnosis_inagrouper"
			],
			"data" => [
				"keyword" => $data["query"]
			]
		];
		
		$data = json_encode($request);
		$data = Crypto::encrypt($data, $this->config["key"]);
		
		return json_decode(Crypto::decrypt($this->sendRequest("POST", $data, "application/json"), $this->config["key"])); 
	}

	/**
	  * @method Prosedur INA Grouper
	  * @param $data array
	  * 11. Pencarian prosedur INA Grouper
	  * => Data Request
	  * {
	  *		"metadata": {
	  *			"method": "search_procedures_inagrouper"
	  *		},
	  *		"data": {
	  *			"keyword":"74.9"
	  *		}
	  *	}
	  * @return data response
	  * => Data Response
	  * {
	  *		"metadata": {
	  *			"code":"200",
	  *			"message":"Ok"
	  *		},
	  *		"response": {
	  *			"count": 3,	  
	  *			"data": [
	  *				{
	  *					"description": "Cesarean section of unspecified type",
	  *					"code": "74.9",
	  *					"validcode": "0" // tidak bisa di pilih
	  *				},
	  *				{
	  *					"description": "Hysterotomy to terminate pregnancy",
	  *					"code": "74.91",
	  *					"validcode": "1" // bisa di pilih
	  *				}
	  *			...
	  *			]
	  *		}		  
	  *	}		
	 */		
	public function prosedurInaGrouper($data = []) {
		$request = [
			"metadata" => [
				"method" => "search_procedures_inagrouper"
			],
			"data" => [
				"keyword" => $data["query"]
			]
		];
		
		$data = json_encode($request);
		$data = Crypto::encrypt($data, $this->config["key"]);
		
		return json_decode(Crypto::decrypt($this->sendRequest("POST", $data, "application/json"), $this->config["key"])); 
	}

	/**
	  * @method uploadFilePendukung
	  * @param $data [
	  *		"nomor_sep" => ""
	  *		"file_class" => ""
	  *		"file_name" => ""
	  *		"content" => ""
	  * ]
	  * Untuk Upload File Pendukung Klaim
	  * => Data Request
	  * {
	  *		"metadata": {
	  *			"method": "file_upload"
	  *			"nomor_sep": "0000005ICC20040001"	  
	  *			"file_class": "resume_medis", // resumse_medis, ruang_rawat, laboratorium, radiologi, penunjang_lain, resep_obat, tagihan, kartu_identitas, atau lain_lain
 	  *			"file_name": "resumse.pdf",
	  *		},
	  *		"data": " ... base64_encoded binary file … "
	  *	}
	  * @return data response
	  * => Data Response
	  * {
	  *		"metadata": {
	  *			"code":"200",
	  *			"message":"OK"
	  *		},
	  *		"response": {
	  *			"file_id": "1",
	  *			"file_name" : "resume.pdf",
	  *			"file_type": "application/pdf",
	  *			"file_size" : 130992,
	  *			"file_class" : "resumse_medis",
	  *			"upload_dc_bpjs": 1
	  *		}
	  *	}		
	 */		
	public function uploadFilePendukung($data = []) {
		$request = [
			"metadata" => [
				"method" => "file_upload",
				"nomor_sep" => $data["nomor_sep"],
				"file_class" => $data["file_class"],
				"file_name" => $data["file_name"]
			],
			"data" => $data["content"]
		];
		
		$data = json_encode($request);
		$data = Crypto::encrypt($data, $this->config["key"]);
		
		$result = json_decode(Crypto::decrypt($this->sendRequest("POST", $data, "application/json"), $this->config["key"])); 		
		return $result; 
	}

	/**
	  * @method hapusFilePendukung
	  * @param $data array
	  * Untuk Hapus File Pendukung Klaim
	  * => Data Request
	  * {
	  *		"metadata": {
	  *			"method": "file_delete"
	  *		},
	  *		"data": {
	  *         "nomor_sep": "0000005ICC20040001",  
	  *         "file_id": "1"
	  * 	}
	  *	}
	  * @return data response	  
	 */		
	public function hapusFilePendukung($data = []) {
		$request = [
			"metadata" => [
				"method" => "file_delete"
			],
			"data" => $data
		];
		
		$data = json_encode($request);
		$data = Crypto::encrypt($data, $this->config["key"]);
		
		$result = json_decode(Crypto::decrypt($this->sendRequest("POST", $data, "application/json"), $this->config["key"])); 		
		return $result; 
	}	

	/**
	  * @method daftarFilePendukung
	  * @param $data array
	  * Untuk Daftar File Pendukung Klaim
	  * => Data Request
	  * {
	  *		"metadata": {
	  *			"method": "file_get"
	  *		},
	  *		"data": {
	  *         "nomor_sep": "0000005ICC20040001"
	  * 	}
	  *	}
	  * @return data response
	  * => Data Response
	  * {
	  *		"metadata": {
	  *			"code":"200",
	  *			"message":"OK"
	  *		},
	  *		"response": {
	  *			"count": 7,
	  *			"data" : [{
	  *	  			"file_id": resume.pdf",
	  *	  			"file_name": resume.pdf",
	  *				"file_type": "application/pdf",
	  *				"file_size" : 130992,
	  *				"file_class" : "resumse_medis",
	  *				"upload_dc_bpjs": 1
	  *				"upload_dc_bpjs_response": {
	  *					"metaData": {
	  *						"code": "200",
	  *						"message": "Sukses"
	  *					},
	  *					"response": {
	  *						"keterangan": "Sukses"
	  *					}
	  *				}
	  *			...
	  *			}
	  *		}
	  *	}		
	 */		
	public function daftarFilePendukung($data = []) {
		$request = [
			"metadata" => [
				"method" => "file_get"
			],
			"data" => $data
		];
		
		$data = json_encode($request);
		$data = Crypto::encrypt($data, $this->config["key"]);
		
		$result = json_decode(Crypto::decrypt($this->sendRequest("POST", $data, "application/json"), $this->config["key"])); 		
		return $result; 
	}

	/**
	  * @method validasiNomorRegisterSITB
	  * @param $data array
	  * Untuk memvalidasi nomor register SITB
	  * => Data Request
	  * {
	  *		"metadata": {
	  *			"method": "sitb_validate"
	  *		},
	  *		"data": {
	  *         "nomor_sep": "0000005ICC20040001",
	  *			"nomor_register_sitb": "00000001"
	  * 	}
	  *	}
	  * @return data response
	  * => Data Response
	  * {
	  *		"metadata": {
	  *			"code":"200",
	  *			"message":"Ok"
	  *		},
	  *		"response": {
	  *			"status": "VALID | INVALID",
	  *			"detail": "Nomor register valid | Nomor register tidak ditemukan"
	  *		},
	  *     "validation": {
	  *			"data": [
	  *				"id": "nomor registrasi sitb",
	  *				"nama": "",
	  *				"nik": "",
	  *				"jenis_kelamin": "1|2",
	  *			],
	  *         "success": true|false
	  *     }
	  *	}		
	 */		
	public function validasiNomorRegisterSITB($data = []) {
		$request = [
			"metadata" => [
				"method" => "sitb_validate"
			],
			"data" => $data
		];
		
		$data = json_encode($request);
		$data = Crypto::encrypt($data, $this->config["key"]);
		
		$result = json_decode(Crypto::decrypt($this->sendRequest("POST", $data, "application/json"), $this->config["key"])); 		
		return $result; 
	}

	/**
	  * @method batalValidasiNomorRegisterSITB
	  * @param $data array
	  * Untuk membatalkan validasi nomor register SITB
	  * => Data Request
	  * {
	  *		"metadata": {
	  *			"method": "sitb_invalidate"
	  *		},
	  *		"data": {
	  *         "nomor_sep": "0000005ICC20040001"
	  * 	}
	  *	}
	  * @return data response
	  * => Data Response
	  * {
	  *		"metadata": {
	  *			"code":"200",
	  *			"message":"Ok"
	  *		}
	  *	}		
	 */		
	public function batalValidasiNomorRegisterSITB($data = []) {
		$request = [
			"metadata" => [
				"method" => "sitb_invalidate"
			],
			"data" => $data
		];
		
		$data = json_encode($request);
		$data = Crypto::encrypt($data, $this->config["key"]);
		
		$result = json_decode(Crypto::decrypt($this->sendRequest("POST", $data, "application/json"), $this->config["key"])); 		
		return $result; 
	}
}