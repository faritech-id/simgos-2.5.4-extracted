<?php
/**
 * BPJService
 * @author hariansyah
 * 
 */
 
namespace BPJService\VClaim\v_2_0;

use BPJService\VClaim\v_1_1\Service as BaseService;
use Laminas\Json\Json;
use BPJService\db\kunjungan\Service as KunjunganService;

class SEPService extends BaseService {
	protected $kunjungan;

	function __construct($config) {
		parent::__construct($config);
		$this->kunjungan = new KunjunganService();
	}

	protected function sendRequest($action = "", $method = "GET", $data = "", $contenType = "application/json", $url = "") {
		$result = parent::sendRequest($action, $method, $data, $contenType, $url);
		$result = Json::decode($result);
		if(is_object($result)) {
			if($result->response) {
				$decrypt = $this->decrypt($result->response);
				$result->response = $decrypt ? $decrypt : $result->response;
			}
		}
		return Json::encode($result);
	}

	/* SEP>>>Insert SEP
	 * generate Nomor SEP
	 * @parameter 
	 *   $params [
	 *		"noKartu" => value
	 *		, "tglSep" => value | yyyy-MM-dd
	 *		, "jnsPelayanan" => value | 1 = R. Inap, 2 = R.Jalan
	 *		, "klsRawat" => value // kelasRawatHak
	 *		, "klsRawatNaik" => value 					#NEW VClaim 2.0
	 *      , "pembiayaan" => value						#NEW VClaim 2.0
	 *      , "penanggungJawab" => value				#NEW VClaim 2.0
	 *		, "noMr" => value
	 
	 *		// rujukan
	 *		, "asalRujukan" => value | 1 = Faskes 1, 2 = Faskes 2 (RS)			
	 *		, "tglRujukan" => value | yyyy-MM-dd
	 *		, "noRujukan" => value
	 *		, "ppkRujukan" => value
	 
	 *		, "catatan" => value
	 *		, "diagAwal" => value
	 
	 *		// poli
	 *		, "poliTujuan" => value
	 *		, "eksekutif" => value | 0 = Tidak, 1 = Ya							
	 
	 *		, "cob" => value | 0 = Tidak, 1 = Ya								
	 *		, "katarak" => value | 0 = Tidak, 1 = Ya								
	 *		, "noSuratSKDP" => value                                                
	 *		, "dpjpSKDP" => value                                                   
	 	 
	 *		// jaminan
	 *		, "lakaLantas" => value | 0 : Bukan Kecelakaan lalu lintas [BKLL], 1 : KLL dan bukan kecelakaan Kerja [BKK], 2 : KLL dan KK, 3 : KK" #NEW 221214 # 2 = Tidak, 1 = Ya (OLD) # 0 = Tidak, 1 = Ya (OLD)
	 *		, "noLP" => "" #NEW VClaim 2.0
	 *		, "penjamin" => value | 1=Jasa raharja PT, 2=BPJS Ketenagakerjaan, 3=TASPEN PT, 4=ASABRI PT} jika lebih dari 1 isi -> 1,2 (pakai delimiter koma)
	 *      , "tglKejadian" => value | yyyy-MM-dd                                  
	 *      , "suplesi" => value | Skrg 0 = Tidak, 1 = Ya                          
	 *      , "noSuplesi => value                                                  
	 *		, "lokasiLaka" => value #change to keterangan                          
	 *      , "propinsi" => ""                                                     
	 *      , "kabupaten" => ""                                                    
	 *      , "kecamatan" => ""                                                    
	 
	 *		, "tujuanKunj" => value | "0" = Normal, "1" = Prosedur, "2" = Konsul Dokter		#NEW VClaim 2.0
	 *		, "flagProcedure" => value | "0" = Prosedur Tidak Berkelanjutan, "1" => Prosedur dan Terapi Berkelanjutan ==> diisi "" jika tujuanKunj = "0",	#NEW VClaim 2.0
	 *		, "kdPenunjang" => value | "1" = Radioterapi, "2" = Kemoterapi, "3" = Rehabilitasi Medik, "4" = Rehabilitasi Psikososial, "5" = Transfusi Darah, "6" = Pelayanan Gigi, "7" = Laboratorium, "8" = USG, "9" = Farmasi, "10" = Lain-Lain, "11" = MRI, "12" = HEMODIALISA ==> diisi "" jika tujuanKunj = "0"	#NEW VClaim 2.0
	 *		, "assesmentPel" => value | "1" = Poli spesialis tidak tersedia pada hari sebelumnya, "2" = Jam Poli telah berakhir pada hari sebelumnya, "3" = Dokter Spesialis yang dimaksud tidak praktek pada hari sebelumnya, "4" = Atas Instruksi RS ==> diisi jika tujuanKunj = "2" atau "0" (politujuan beda dengan poli rujukan dan hari beda),	#NEW VClaim 2.0
	 *		, "dpjpLayan" => value | tidak diisi jika jnsPelayanan = "1" (RANAP)
	 *		, "noTelp" => value
	 *		, "user" => value
	 *   ],
	 *   $uri string
	 */	
	function generateNoSEP($params = [], $uri = "SEP/2.0/insert") {
		$paket = $params;

		$paket["klsRawat"] = [
			"klsRawatHak" => "",
			"klsRawatNaik" => "",
			"pembiayaan" => "",
			"penanggungJawab" => ""
		];
		if(!empty($paket["klsRawatNaik"])) {
			$paket["klsRawat"]["klsRawatNaik"] = strval($paket["klsRawatNaik"]);
			unset($paket["klsRawatNaik"]);
		} else {
			if(isset($paket["klsRawatNaik"])) unset($paket["klsRawatNaik"]);
		}
		if(!empty($paket["pembiayaan"])) {
			$paket["klsRawat"]["pembiayaan"] = strval($paket["pembiayaan"]);
			unset($paket["pembiayaan"]);
		} else {
			if(isset($paket["pembiayaan"])) unset($paket["pembiayaan"]);
		}
		if(!empty($paket["penanggungJawab"])) {
			$paket["klsRawat"]["penanggungJawab"] = strval($paket["penanggungJawab"]);
			unset($paket["penanggungJawab"]);
		} else {
			if(isset($paket["penanggungJawab"])) unset($paket["penanggungJawab"]);
		}

		$paket["rujukan"] = [
			"asalRujukan" => "1"
			, "tglRujukan" => ""
			, "noRujukan" => ""
			, "ppkRujukan" => ""
		];
		if(isset($paket["asalRujukan"])) {
			$paket["rujukan"]["asalRujukan"] = strval($paket["asalRujukan"]);
			unset($paket["asalRujukan"]);
		}
		if(isset($paket["tglRujukan"])) {
			$paket["rujukan"]["tglRujukan"] = substr($paket["tglRujukan"], 0, 10);
			unset($paket["tglRujukan"]);
		}
		if(!empty($paket["noRujukan"])) {
			$paket["rujukan"]["noRujukan"] = $paket["noRujukan"];
			unset($paket["noRujukan"]);
		} else {
			if(isset($paket["noRujukan"])) unset($paket["noRujukan"]);
		}
		if(isset($paket["ppkRujukan"])) {
			$paket["rujukan"]["ppkRujukan"] = $paket["ppkRujukan"];
			unset($paket["ppkRujukan"]);
		}
		
		$paket["poli"] = [
			"tujuan" => ""
			, "eksekutif" => "0"
		];
		
		if(isset($paket["poliTujuan"])) {
			$paket["poli"]["tujuan"] = $paket["poliTujuan"];
			unset($paket["poliTujuan"]);
		}
		if(isset($paket["eksekutif"])) {
			$paket["poli"]["eksekutif"] = strval($paket["eksekutif"]);
			unset($paket["eksekutif"]);
		}
		
		if(isset($paket["cob"])) {
			$paket["cob"] = [
				"cob" => strval($paket["cob"])
			];
		} else {
			$paket["cob"] = [
				"cob" => "0"
			];
		}
		
		if(isset($paket["katarak"])) {
		    $paket["katarak"] = [
		        "katarak" => strval($paket["katarak"])
		    ];
		} else {
		    $paket["katarak"] = [
		        "katarak" => "0"
		    ];
		}
		
		$paket["skdp"] = [
		    "noSurat" => ""
		    , "kodeDPJP" => ""
		];
		if(isset($paket["noSuratSKDP"])) {
		    $paket["skdp"]["noSurat"] = $paket["noSuratSKDP"];
		    unset($paket["noSuratSKDP"]);
		}
		if(isset($paket["dpjpSKDP"])) {
		    $paket["skdp"]["kodeDPJP"] = $paket["dpjpSKDP"];
		    unset($paket["dpjpSKDP"]);
		}
		
		$paket["jaminan"] = [
			"lakaLantas" => "0",
			"noLP" => "",
		    "penjamin" => [
		        "penjamin" => "0",
		        "tglKejadian" => "",
		        "keterangan" => "",
		        "suplesi" => [
		            "suplesi" => "0",
		            "noSepSuplesi" => "",
		            "lokasiLaka" => [
		                "kdPropinsi" => "",
		                "kdKabupaten" => "",
		                "kdKecamatan" => ""
		            ]
		        ]		        
		    ]
			//, "penjamin" => "0"
			//, "lokasiLaka" => "-"
		];
		if(isset($paket["lakaLantas"])) {
			$paket["jaminan"]["lakaLantas"] = strval($paket["lakaLantas"]);
			unset($paket["lakaLantas"]);
		}
		if(isset($paket["noLP"])) {
			$paket["jaminan"]["noLP"] = $paket["noLP"];
			unset($paket["noLP"]);
		}
		if(isset($paket["penjamin"])) {
		    $paket["jaminan"]["penjamin"]["penjamin"] = strval($paket["penjamin"]);
			unset($paket["penjamin"]);
		}
		if(isset($paket["tglKejadian"])) {
		    $paket["jaminan"]["penjamin"]["tglKejadian"] = strval($paket["tglKejadian"]);
		    unset($paket["tglKejadian"]);
		}
		if(isset($paket["lokasiLaka"])) {
		    $paket["jaminan"]["penjamin"]["keterangan"] = $paket["lokasiLaka"];
			unset($paket["lokasiLaka"]);
		}
		if(isset($paket["suplesi"])) {
		    $paket["jaminan"]["penjamin"]["suplesi"]["suplesi"] = strval($paket["suplesi"]);
		    unset($paket["suplesi"]);
		}
		if(isset($paket["noSuplesi"])) {
		    $paket["jaminan"]["penjamin"]["suplesi"]["noSepSuplesi"] = $paket["noSuplesi"];
		    unset($paket["noSuplesi"]);
		}
		if(isset($paket["propinsi"])) {
		    $paket["jaminan"]["penjamin"]["suplesi"]["lokasiLaka"]["kdPropinsi"] = $paket["propinsi"];
		    unset($paket["propinsi"]);
		}
		if(isset($paket["kabupaten"])) {
		    $paket["jaminan"]["penjamin"]["suplesi"]["lokasiLaka"]["kdKabupaten"] = $paket["kabupaten"];
		    unset($paket["kabupaten"]);
		}
		if(isset($paket["kecamatan"])) {
		    $paket["jaminan"]["penjamin"]["suplesi"]["lokasiLaka"]["kdKecamatan"] = $paket["kecamatan"];
		    unset($paket["kecamatan"]);
		}
		
		$paket["catatan"] = isset($paket["catatan"]) ? $paket["catatan"] : "-";
		$paket["noTelp"] = isset($paket["noTelp"]) ? $paket["noTelp"] : "-";
		
		$peserta = null;
		$kunjungan = null;
		$metaData = [
			'message' => 200,
			'code' => 200,
			'requestId'=> $this->config["koders"]
		];
		
		if($peserta == null) {
			try {
				$rPeserta = $this->peserta->load(["noKartu" => $params["noKartu"]]);
				if(count($rPeserta) > 0) {
					$rPeserta = $rPeserta[0];
					$peserta = $this->pesertaTableToFormatBPJS($rPeserta);
					$peserta = json_decode(json_encode($peserta));
				} else {
					$metaData['message'] = "SIMRSInfo::Peserta tidak terdaftar di simgos<br/>Silahkan lakukan pencarian peserta terlebih dahulu";
					$metaData['code'] = 404;
				}
			} catch(\Exception $e) {
				$metaData['message'] = "SIMRSInfo::Error Query Select";
				$metaData['code'] = 500;
			}
		}
								  
		if($metaData['code'] == 200) {
			$paket["ppkPelayanan"] = $this->config["koders"];
			if(!empty($params["klsRawat"])) $paket["klsRawat"]["klsRawatHak"] = strval($params["klsRawat"]);
			else $paket["klsRawat"]["klsRawatHak"] = strval($paket["jnsPelayanan"] == 2 ? 3 : $peserta->hakKelas->kode);
			$paket["noMR"] = strval($params["norm"]);
			$paket["tglSep"] = substr($paket["tglSep"], 0, 10);
			$paket["jnsPelayanan"] = strval($params["jnsPelayanan"]);	
			$paket["tujuanKunj"] = strval($params["tujuanKunj"]);
			$paket["flagProcedure"] = strval($params["flagProcedure"]);
			$paket["kdPenunjang"] = strval($params["kdPenunjang"]);
			$paket["assesmentPel"] = strval($params["assesmentPel"]);
			
			if($params["jnsPelayanan"] == '1') $paket["dpjpLayan"] = "";
			unset($paket["create"]);
			unset($paket["ip"]);
			unset($paket["norm"]);
			
			$data = json_encode([
				"request" => [
					"t_sep" => $paket
				]
			]);
			
			$result = json_decode($this->sendRequest($uri, "POST", $data, "Application/x-www-form-urlencoded"));
			
			if($result) {
				if($result->metadata->code == 200 && $result->response != null) {
					$params["noSEP"] = $result->response->sep->noSep;
					$params["tglSEP"] = $params["tglSep"];
					$params["ppkPelayanan"] = $this->config["koders"];
					$params["jenisPelayanan"] = $params["jnsPelayanan"];
					$params["klsRawat"] = $paket["klsRawat"]["klsRawatHak"];
					
					$rKunjungan = $this->kunjungan->load([
						"noKartu" => $params["noKartu"]
						, "noSEP" => $params["noSEP"]
					]);
					
					$this->kunjungan->simpan($params, count($rKunjungan) == 0);						
					$kunjungan = $params;
					unset($kunjungan["jenisPelayanan"]);
					unset($kunjungan["ip"]);
					unset($kunjungan["create"]);
				   
					$metaData['message'] = 200;
					$metaData['code'] = 200;
				} else {
					$metaData['message'] = $result == null ? "SIMRSInfo::Error" : $result->metadata->message." ".(is_string($result->response) ? $result->response : "");
					$metaData['code'] = $result == null ? 400 : $result->metadata->code;
				}
			} else {
				return json_decode(json_encode([					
					'metadata' => [
						'message' => "SIMRSInfo::Error Request Service - generate Nomor SEP<br/>".$this::RESULT_IS_NULL,
						'code' => 502,
						'requestId'=> $this->config["koders"]
					]
				]));
			}
		}
					
		return json_decode(json_encode([
			'response' => [
				'peserta' => $peserta,
				'kunjungan' => $kunjungan
			],
			'metadata' => $metaData
		]));
	}
	
	/* SEP>>>Update SEP
	 * Update SEP
	 * @parameter
	 *   $params [
	 *		"noSep" => value
	 *		, "klsRawat" => value // kelasRawatHak
	 *		, "klsRawatNaik" => value 					#NEW VClaim 2.0
	 *      , "pembiayaan" => value						#NEW VClaim 2.0
	 *      , "penanggungJawab" => value				#NEW VClaim 2.0
	 *		, "noMr" => value
	 	 
	 *		, "catatan" => value
	 *		, "diagAwal" => value
	 
	 *		// poli
	 *		, "poliTujuan" => value
	 *		, "eksekutif" => value | 0 = Tidak, 1 = Ya							
	 
	 *		, "cob" => value | 0 = Tidak, 1 = Ya								
	 *		, "katarak" => value | 0 = Tidak, 1 = Ya								#ADDED
	 	 
	 *		// jaminan
	 *		, "lakaLantas" => value | 0 : Bukan Kecelakaan lalu lintas [BKLL], 1 : KLL dan bukan kecelakaan Kerja [BKK], 2 : KLL dan KK, 3 : KK" #NEW 221214 # 2 = Tidak, 1 = Ya (OLD) # 0 = Tidak, 1 = Ya (OLD)
	 *		, "penjamin" => value | 1=Jasa raharja PT, 2=BPJS Ketenagakerjaan, 3=TASPEN PT, 4=ASABRI PT} jika lebih dari 1 isi -> 1,2 (pakai delimiter koma)
	 *      , "tglKejadian" => value | yyyy-MM-dd                                  #ADDED
	 *      , "suplesi" => value | Skrg 0 = Tidak, 1 = Ya                          #ADDED
	 *      , "noSuplesi => value                                                  #ADDED
	 *		, "lokasiLaka" => value #change to keterangan                          #CHANGED
	 *      , "propinsi" => ""                                                     #ADDED
	 *      , "kabupaten" => ""                                                    #ADDED
	 *      , "kecamatan" => ""                                                    #ADDED
	 
	 *		, "dpjpLayan" => value | tidak diisi jika jnsPelayanan = "1" (RANAP)
	 *		, "noTelp" => value													
	 *		, "user" => value
	 *)
	 *   $uri string
	 */	
	function updateSEP($params, $uri = "SEP/2.0/update") {		
		$paket = $params;
		
		$paket["klsRawat"] = [
			"klsRawatHak" => "",
			"klsRawatNaik" => "",
			"pembiayaan" => "",
			"penanggungJawab" => ""
		];
		
		if(!empty($paket["klsRawatNaik"])) {
			$paket["klsRawat"]["klsRawatNaik"] = strval($paket["klsRawatNaik"]);
			unset($paket["klsRawatNaik"]);
		}
		if(!empty($paket["pembiayaan"])) {
			$paket["klsRawat"]["pembiayaan"] = strval($paket["pembiayaan"]);
			unset($paket["pembiayaan"]);
		}
		if(!empty($paket["penanggungJawab"])) {
			$paket["klsRawat"]["penanggungJawab"] = strval($paket["penanggungJawab"]);
			unset($paket["penanggungJawab"]);
		}

		$paket["poli"] = [
			"tujuan" => "", 
			"eksekutif" => "0"
		];
		if(isset($paket["poliTujuan"])) {
			$paket["poli"]["tujuan"] = $paket["poliTujuan"];
			unset($paket["poliTujuan"]);
		}
		if(isset($paket["eksekutif"])) {
			$paket["poli"]["eksekutif"] = strval($paket["eksekutif"]);
			unset($paket["eksekutif"]);
		}
						
		if(isset($paket["cob"])) {
			$paket["cob"] = [
				"cob" => strval($paket["cob"])
			];
		} else {
			$paket["cob"] = [
				"cob" => "0"
			];
		}
		
		if(isset($paket["katarak"])) {
		    $paket["katarak"] = [
		        "katarak" => strval($paket["katarak"])
		    ];
		} else {
		    $paket["katarak"] = [
		        "katarak" => "0"
		    ];
		}
		
		$paket["jaminan"] = [
		    "lakaLantas" => "0",
		    "penjamin" => [
		        "tglKejadian" => "",
		        "keterangan" => "",
		        "suplesi" => [
		            "suplesi" => "0",
		            "noSepSuplesi" => "",
		            "lokasiLaka" => [
		                "kdPropinsi" => "",
		                "kdKabupaten" => "",
		                "kdKecamatan" => ""
		            ]
		        ]
		    ]
		];
		if(isset($paket["lakaLantas"])) {
		    $paket["jaminan"]["lakaLantas"] = strval($paket["lakaLantas"]);
		    unset($paket["lakaLantas"]);
		}
		/*
		if(isset($paket["noLP"])) {
			$paket["jaminan"]["noLP"] = $paket["noLP"];
			unset($paket["noLP"]);
		}
		*/
		/*if(isset($paket["penjamin"])) {
		    $paket["jaminan"]["penjamin"]["penjamin"] = strval($paket["penjamin"]);
		    unset($paket["penjamin"]);
		}*/
		if(isset($paket["tglKejadian"])) {
		    $paket["jaminan"]["penjamin"]["tglKejadian"] = strval($paket["tglKejadian"]);
		    unset($paket["tglKejadian"]);
		}
		if(isset($paket["lokasiLaka"])) {
		    $paket["jaminan"]["penjamin"]["keterangan"] = $paket["lokasiLaka"];
		    unset($paket["lokasiLaka"]);
		}
		if(isset($paket["suplesi"])) {
		    $paket["jaminan"]["penjamin"]["suplesi"]["suplesi"] = strval($paket["suplesi"]);
		    unset($paket["suplesi"]);
		}
		if(isset($paket["noSuplesi"])) {
		    $paket["jaminan"]["penjamin"]["suplesi"]["noSepSuplesi"] = $paket["noSuplesi"];
		    unset($paket["noSuplesi"]);
		}
		if(isset($paket["propinsi"])) {
		    $paket["jaminan"]["penjamin"]["suplesi"]["lokasiLaka"]["kdPropinsi"] = $paket["propinsi"];
		    unset($paket["propinsi"]);
		}
		if(isset($paket["kabupaten"])) {
		    $paket["jaminan"]["penjamin"]["suplesi"]["lokasiLaka"]["kdKabupaten"] = $paket["kabupaten"];
		    unset($paket["kabupaten"]);
		}
		if(isset($paket["kecamatan"])) {
		    $paket["jaminan"]["penjamin"]["suplesi"]["lokasiLaka"]["kdKecamatan"] = $paket["kecamatan"];
		    unset($paket["kecamatan"]);
		}
		
		$paket["catatan"] = isset($paket["catatan"]) ? $paket["catatan"] : "-";
		$paket["noTelp"] = isset($paket["noTelp"]) ? $paket["noTelp"] : "-";
		
		$peserta = null;
		$kunjungan = null;
		$metaData = [
			'message' => 200,
			'code' => 200,
			'requestId'=> $this->config["koders"]
		];
		
		if($peserta == null) {
			try {
				$rPeserta = $this->peserta->load(["noKartu" => $params["noKartu"]]);
				if(count($rPeserta) > 0) {
					$rPeserta = $rPeserta[0];
					$peserta = $this->pesertaTableToFormatBPJS($rPeserta);
					$peserta = json_decode(json_encode($peserta));
				} else {
					$metaData['message'] = "SIMRSInfo::Peserta tidak terdaftar di simgos<br/>Silahkan lakukan pencarian peserta terlebih dahulu";
					$metaData['code'] = 404;
				}
			} catch(\Exception $e) {
				$metaData['message'] = "SIMRSInfo::Error Query Select";
				$metaData['code'] = 500;
			}
		}
							  
		if($metaData['code'] == 200) {
			if(!empty($params["klsRawat"])) $paket["klsRawat"]["klsRawatHak"] = strval($params["klsRawat"]);
			else $paket["klsRawat"]["klsRawatHak"] = strval($paket["jnsPelayanan"] == 2 ? 3 : $peserta->hakKelas->kode);
			$paket["noMR"] = strval($params["norm"]);	
			$paket["dpjpLayan"] = strval($params["dpjpLayan"]);

			if(isset($paket["create"])) unset($paket["create"]);
			if(isset($paket["ip"])) unset($paket["ip"]);
			if(isset($paket["norm"])) unset($paket["norm"]);
			if(isset($paket["noKartu"])) unset($paket["noKartu"]);
			if(isset($paket["tglSep"])) unset($paket["tglSep"]);
			if(isset($paket["poliTujuan"])) unset($paket["poliTujuan"]);
			if(isset($paket["jnsPelayanan"])) unset($paket["jnsPelayanan"]);

			if(isset($paket["tglRujukan"])) unset($paket["tglRujukan"]);
			if(isset($paket["noRujukan"])) unset($paket["noRujukan"]);
			if(isset($paket["noSuratSKDP"])) unset($paket["noSuratSKDP"]);
			if(isset($paket["dpjpSKDP"])) unset($paket["dpjpSKDP"]);
			if(isset($paket["tujuanKunj"])) unset($paket["tujuanKunj"]);
			if(isset($paket["flagProcedure"])) unset($paket["flagProcedure"]);
			if(isset($paket["kdPenunjang"])) unset($paket["kdPenunjang"]);
			if(isset($paket["assesmentPel"])) unset($paket["assesmentPel"]);
			if(isset($paket["penjamin"])) unset($paket["penjamin"]);
			if(isset($paket["noSuplesi"])) unset($paket["noSuplesi"]);
			
			$data = json_encode([
				"request" => [
					"t_sep" => $paket
				]
			]);
			
			$result = json_decode($this->sendRequest($uri, "PUT", $data, "Application/x-www-form-urlencoded"));			
			if($result) {
				if($result->metadata->code == 200 && $result->response != null) {
					$params["noSEP"] = $params["noSep"];
					$params["klsRawat"] = $paket["klsRawat"]["klsRawatHak"];
					
					$rKunjungan = $this->kunjungan->load([
						"noKartu" => $params["noKartu"]
						, "noSEP" => $params["noSEP"]
					]);
					
					$this->kunjungan->simpan($params, count($rKunjungan) == 0);						
					$kunjungan = $params;
					unset($kunjungan["jenisPelayanan"]);
					unset($kunjungan["ip"]);
					unset($kunjungan["create"]);
					
					$metaData['message'] = 200;
					$metaData['code'] = 200;
				} else {
					$metaData['message'] = $result == null ? "SIMRSInfo::Error" : $result->metadata->message." ".(is_string($result->response) ? $result->response : "");
					$metaData['code'] = $result == null ? 400 : $result->metadata->code;
				}
			} else {
				return json_decode(json_encode([					
					'metadata' => [
						'message' => "SIMRSInfo::Error Request Service - Update SEP<br/>".$this::RESULT_IS_NULL,
						'code' => 502,
						'requestId'=> $this->config["koders"]
					]
				]));
			}
		}
					
		return json_decode(json_encode([
			'response' => [
				'peserta' => $peserta,
				'kunjungan' => $kunjungan
			],
			'metadata' => $metaData
		]));
	}

	/* SEP>>Detail SEP Peserta
	 * Mencari detail SEP / Cek SEP
	 * Melihat detail keterangan dari SEP.
	 * @parameter 
	 *   $params array(
	 *		"noSEP" => value
	 *)
	 *   $uri string
	 */
	function cekSEP($params, $uri = "SEP/") {	
		$result = parent::cekSEP($params, $uri);
		if($result) {
			if($result->metadata->code == 200) {
				$data = (array) $result->response;
				$data["peserta"] = (array) $data["peserta"];
				$data["klsRawat"] = (array) $data["klsRawat"];
				$finds = $this->kunjungan->load([
					"noSEP" => $data["noSep"]
				]);
				if(count($finds) == 0) $this->kunjungan->simpan([
					"noKartu" => $data["peserta"]["noKartu"],
					"noSEP" => $data["noSep"],
					"tglSEP" => $data["tglSep"],
					"poliTujuan" => $data["poli"],
					"noRujukan" => $data["noRujukan"],
					"diagAwal" => $data["diagnosa"],
					"jenisPelayanan" => $data["jnsPelayanan"] == "Rawat Inap" ? 1 : 2,
					"eksekutif" => $data["poliEksekutif"],
					"klsRawat" => $data["klsRawat"]["klsRawatHak"],
					"klsRawatNaik" => $data["klsRawat"]["klsRawatNaik"],
					"pembiayaan" => $data["klsRawat"]["pembiayaan"],
					"penanggungJawab" => $data["klsRawat"]["penanggungJawab"],
					"cob" => $data["cob"],
					"katarak" => $data["katarak"],
				], true, false);
			}
		}
		return $result;
	}

	/* SEP>>>Hapus SEP
	 * batalkanNoSEP
	 * Data SEP yang dapat dihapus hanya jika data tersebut belum dibuatkan FPK/tagihan ke Kantor Cabang BPJS setempat
	 * @parameter 
	 *   $params array(
	 *		"noSEP" => value
	 *		"user" => value
	 *)
	 *   $uri string
	 */
	function batalkanSEP($params, $uri = "SEP/2.0/delete") {
		return parent::batalkanSEP($params, $uri);
	}

	/* SEP>>>Suplesi Jasa Raharja
	 * @parameter 
	 *   $params [ 
	 *       "noKartu" => value
	 * 		 "tglPelayanan" => value | atau tgl SEP
	 *   ],
	 *   $uri string
	 */
	function suplesiJasaRaharja($params, $uri = "sep/JasaRaharja/Suplesi") {
	    $kartu = "/";
		$pelayanan = "/"."tglPelayanan/";
	    if(is_array($params)) {
			$kartu .= !empty($params["noKartu"]) ? $params["noKartu"] : "0";
			if(!empty($params["tglPelayanan"])) $pelayanan .= !empty($params["tglPelayanan"]) ? $params["tglPelayanan"] : date("Y-m-d");
	    } else {
			$kartu .= "0";
			$pelayanan .= date("Y-m-d");
		}
		$result = Json::decode($this->sendRequest($uri.$kartu.$pelayanan));
	    if($result) {
	        $result->metadata->requestId = $this->config["koders"];
	        if($result->response) {
	            $data = isset($result->response->jaminan) ? (array) $result->response->jaminan : [];
	            $result->response->list = $data;
	            $result->response->count = count($data);
	        }
	    } else {
	        return json_decode(json_encode([
	            'metadata' => [
	                'message' => "SIMRSInfo::Error Request Service - Suplesi Jasa Raharja<br/>".$this::RESULT_IS_NULL,
	                'code' => 502,
	                'requestId'=> $this->config["koders"]
				]
			]));
	    }
	    return $result;
	}

	/* SEP>>>Data Induk Kecelakaan
	 * @parameter 
	 *   $params [ 
	 *       "noKartu" => value
	 *   ],
	 *   $uri string
	 */
	function dataIndukKecelakaan($params, $uri = "sep/KllInduk/List/") {
	    $kartu = $params;
	    if(is_array($params)) {
			if(isset($params["noKartu"])) $kartu = $params["noKartu"];
	    }
		$result = Json::decode($this->sendRequest($uri.$kartu));
	    if($result) {
	        $result->metadata->requestId = $this->config["koders"];
	        if($result->response) {
	            $data = isset($result->response->list) ? (array) $result->response->list : [];
	            $result->response->list = $data;
	            $result->response->count = count($data);
	        }
	    } else {
	        return json_decode(json_encode([
	            'metadata' => [
	                'message' => "SIMRSInfo::Error Request Service - Data Induk Kecelakaan<br/>".$this::RESULT_IS_NULL,
	                'code' => 502,
	                'requestId'=> $this->config["koders"]
				]
			]));
	    }
	    return $result;
	}

	/* SEP>>>Update Tanggal Pulang
	 * updateTanggalPulang	 
	 * @parameter 
	 *   $params array(
	 *		"noSEP" => value
	 *		, "tglPlg" => value | format Y-m-d H:i:s	
	 *      , "statusPulang" => "{1:Atas Persetujuan Dokter, 3:Atas Permintaan Sendiri, 4:Meninggal, 5:Lain-lain}"
	 *      , "noSuratMeninggal" => "{diisi jika statusPulang 4, selain itu kosong}"
	 *      , "tglMeninggal" => "{diisi jika statusPulang 4, selain itu kosong. format yyyy-MM-dd}"
	 *      , "noLPManual" => "{diisi jika SEPnya adalah KLL}"
	 *      , "user" => "{user}"
	 *)
	 *   $uri string
	 */
	function updateTanggalPulang($params, $uri = "SEP/2.0/updtglplg") {		
		$data = json_encode([
			"request" => [
				"t_sep" => [
					"noSep" => $params["noSEP"]
					, "tglPulang" => substr($params["tglPlg"], 0, 10)
					, "statusPulang" => $params["statusPulang"]
					, "noSuratMeninggal" => empty($params["noSuratMeninggal"]) ? "" : $params["noSuratMeninggal"]
					, "tglMeninggal" => empty($params["tglMeninggal"]) ? "" : substr($params["tglMeninggal"], 0, 10)
					, "noLPManual" => empty($params["noLPManual"]) ? "" : $params["noLPManual"]
					, "user" => $params["user"]
				]
			]
		]);
		
		$result =  json_decode($this->sendRequest($uri, "PUT", $data, "application/x-www-form-urlencoded"));		
		if($result) { 
			$message = trim($result->metadata->message);
			$result->metadata->requestId = $this->config["koders"];
			
			if($result->metadata->code == 200) {
				$this->kunjungan->simpan($params);
			} else {
				if($result->metadata != null) {
					$message = $result->metadata->code."-".$message;
					$this->kunjungan->simpan([
						"noSEP" => $params["noSEP"]
						, "errMsgUptTglPlg" => $message
					]);
				}
			}
		} else {
			return json_decode(json_encode([
				'metadata' => [
					'message' => "SIMRSInfo::Error Request Service - updateTanggalPulang<br/>".$this::RESULT_IS_NULL,
					'code' => 502,
					'requestId'=> $this->config["koders"]
				]
			]));
		}
		
		return $result;
	}

	/* SEP>>>List Data Update Tanggal Pulang
	 * @parameter 
	 *   $params [ 
	 *       "bulan" => (1-12)
	 *       "tahun" => (1-12)
	 * 		 "filter" => value | (Apabila dikosongkan akan menampilkan semua data pada bulan dan tahun pilihan)
	 *   ],
	 *   $uri string
	 */
	function listDataUpdateTanggalPulang($params, $uri = "Sep/updtglplg/list") {
	    $bulan = "/"."bulan/";
		$tahun = "/"."tahun/";
		$filter = "/";
	    if(is_array($params)) {
			$bulan .= !empty($params["bulan"]) ? $params["bulan"] : date("m");
			if(!empty($params["tahun"])) $tahun .= !empty($params["tahun"]) ? $params["tahun"] : date("Y");
			if(!empty($params["filter"])) $filter .= "/".$params["filter"];
		} else {
			$bulan .= date("m");
			$tahun .= date("Y");
		}
		$result = Json::decode($this->sendRequest($uri.$bulan.$tahun.$filter));
	    if($result) {
	        $result->metadata->requestId = $this->config["koders"];
	        if($result->response) {
	            $data = isset($result->response->list) ? (array) $result->response->list : [];
	            $result->response->list = $data;
	            $result->response->count = count($data);
	        }
	    } else {
	        return json_decode(json_encode([
	            'metadata' => [
	                'message' => "SIMRSInfo::Error Request Service - List Data Update Tanggal Pulang<br/>".$this::RESULT_IS_NULL,
	                'code' => 502,
	                'requestId'=> $this->config["koders"]
				]
			]));
	    }
	    return $result;
	}

	/** 
	 * SEP>>Aproval Pengajuan SEP
	 * Pengajuan SEP
	 * @parameter 
	 *   $params array(
	 *		"noKartu" => value,
	 *		"tglSep" => value,
	 *		"jnsPelayanan" => value, | jenis pelayanan (1.R.Inap 2.R.Jalan)
	 *		"jnsPengajuan" => value, | jenis pengajuan (1. pengajuan backdate, 2. pengajuan finger print)
	 *		"keterangan" => value,
	 *		"user" => value,
	 *)
	 *   $uri string
	 */
	function pengajuanSEP($params, $uri = "Sep/pengajuanSEP") {
		return parent::pengajuanSEP($params, $uri);
	}

	/**
	 * SEP>>Aproval Pengajuan SEP
	 * Aproval Pengajuan SEP
	 * @parameter 
	 *   $params array(
	 *		"noKartu" => value,
	 *		"tglSep" => value,
	 *		"jnsPelayanan" => value, | jenis pelayanan (1.R.Inap 2.R.Jalan)
	 *		"jnsPengajuan" => value, | jenis pengajuan (1. pengajuan backdate, 2. pengajuan finger print)
	 *		"keterangan" => value,
	 *		"user" => value,
	 *)
	 *   $uri string
	 */
	function aprovalPengajuanSEP($params, $uri = "Sep/aprovalSEP") {
		return parent::aprovalPengajuanSEP($params, $uri);
	}

	/* SEP>>>Data SEP Internal	 
	 * @parameter 
	 *   $params [ 
	 *       "noSEP" => value
	 *   ],
	 *   $uri string
	 */
	function sepInternal($params, $uri = "SEP/Internal/") {
	    $sep = $params;
	    if(is_array($params)) {
			$sep = empty($params["noSEP"]) ? "" : $params["noSEP"];
	    }

		$result = Json::decode($this->sendRequest($uri.$sep));
	    if($result) {
	        $result->metadata->requestId = $this->config["koders"];
	        if($result->response) {
	            $data = isset($result->response->list) ? (array) $result->response->list : [];
	            $result->response->list = $data;
	            $result->response->count = count($data);
	        }
	    } else {
	        return json_decode(json_encode([
	            'metadata' => [
	                'message' => "SIMRSInfo::Error Request Service - Data SEP Internal<br/>".$this::RESULT_IS_NULL,
	                'code' => 502,
	                'requestId'=> $this->config["koders"]
				]
			]));
	    }
	    return $result;
	}

	/* SEP>>>Hapus SEP Internal	 
	 * @parameter 
	 *   $params [ 
	 *       "noSep" => value
	 *       , "noSurat" => value
	 *       , "tglRujukanInternal" => "{tglRujukanInternal, format : yyyy-MM-dd}"
	 * 		 , "kdPoliTuj" => "{kdPoli, 3 digit}"
	 *       , "user" => value
	 *   ],
	 *   $uri string
	 */
	function hapusSepInternal($params, $uri = "SEP/Internal/delete") {
		$data = json_encode([
			"request" => [
				"t_sep" => $params
			]
		]);
		
		$result =  json_decode($this->sendRequest($uri, "DELETE", $data, "application/x-www-form-urlencoded"));		
		if($result) { 
			$result->metadata->requestId = $this->config["koders"];
		} else {
			return json_decode(json_encode([
				'metadata' => [
					'message' => "SIMRSInfo::Error Request Service - Hapus SEP Internal<br/>".$this::RESULT_IS_NULL,
					'code' => 502,
					'requestId'=> $this->config["koders"]
				]
			]));
		}
		
		return $result;
	}

	/** 
	 * SEP>>>Get Finger Print
	 * Pencarian data fingerprint
	 * @parameter 
	 *   $params [ 
	 *       "noKartu" => value,
	 *       "tglPelayanan" => value
	 *   ],
	 *   $uri string
	 */
	function getFingerPrint($params, $uri = "SEP/FingerPrint") {
		$nomor = "/"."Peserta/";
		$tgl = "/"."TglPelayanan/";
	    if(is_array($params)) {
			if(isset($params["noKartu"])) $nomor .= $params["noKartu"];
			if(isset($params["tglPelayanan"])) $tgl .= $params["tglPelayanan"];
	    }

		$result = Json::decode($this->sendRequest($uri.$nomor.$tgl));
	    if($result) {
	        $result->metadata->requestId = $this->config["koders"];
	    } else {
	        return json_decode(json_encode([
	            'metadata' => [
	                'message' => "SIMRSInfo::Error Request Service - Get Finger Print<br/>".$this::RESULT_IS_NULL,
	                'code' => 502,
	                'requestId'=> $this->config["koders"]
				]
			]));
	    }
	    return $result;
	}

	/** 
	 * SEP>>>Get List Finger Print
	 * List Finger Print
	 * @parameter 
	 *   $params [ 
	 *       "tglPelayanan" => value
	 *   ],
	 *   $uri string
	 */
	function getListFingerPrint($params, $uri = "SEP/FingerPrint/List/Peserta") {
		$tgl = "/"."TglPelayanan/";
	    if(is_array($params)) {
			if(isset($params["tglPelayanan"])) $tgl .= $params["tglPelayanan"];
	    }

		$result = Json::decode($this->sendRequest($uri.$tgl));
	    if($result) {
	        $result->metadata->requestId = $this->config["koders"];
			if($result->response) {
	            $data = isset($result->response->list) ? (array) $result->response->list : [];
	            $result->response->list = $data;
	            $result->response->count = count($data);
	        }
	    } else {
	        return json_decode(json_encode([
	            'metadata' => [
	                'message' => "SIMRSInfo::Error Request Service - Get List Finger Print<br/>".$this::RESULT_IS_NULL,
	                'code' => 502,
	                'requestId'=> $this->config["koders"]
				]
			]));
	    }
	    return $result;
	}

	function getFingerAppRequestAccess($params) {
		$cf = $this->config["finger"]["app"];
		$to = $cf["waitLogin"] + $cf["waitInputNomor"] + $cf["waitFinger"];
		$winExit = isset($cf["windowExit"]) ? ";".$cf["windowExit"] : "";
		$content = "AFTER;".
			base64_encode(
				$cf["waitLogin"].";".
				base64_encode($cf["username"]).";".
				base64_encode($cf["password"]).";".
				$cf["waitInputNomor"].";".$params["jenis"].";".$params["nomor"].";".$cf["waitFinger"].$winExit
			);
			
		return json_decode(json_encode([
			'metadata' => [
				'message' => "Ok",
				'code' => 200,
				'requestId'=> $this->config["koders"]
			],
			"response" => [
				"content" => $content,
				"timeout" => $to
			]
		]));
	}
}