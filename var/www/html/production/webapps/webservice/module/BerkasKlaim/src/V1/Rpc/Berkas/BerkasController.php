<?php
namespace BerkasKlaim\V1\Rpc\Berkas;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\RPCResource;
use Pendaftaran\V1\Rest\Penjamin\PenjaminService;
use Pendaftaran\V1\Rest\Kunjungan\KunjunganService;
use Layanan\V1\Rest\TindakanMedis\TindakanMedisService;
use Layanan\V1\Rest\Farmasi\FarmasiService;
use INACBGService\db\dokumen_pendukung\Service as DokumenPendukungService;
use Pembayaran\V1\Rest\TagihanPendaftaran\TagihanPendaftaranService;
use Pembayaran\V1\Rest\PenjaminTagihan\PenjaminTagihanService;
use Layanan\V1\Rest\HasilPa\HasilPaService;
use Layanan\V1\Rest\HasilEvaluasiSST\Service as HasilEvaluasiSST;

use MedicalRecord\V1\Rest\PemeriksaanEeg\Service as EEG;
use MedicalRecord\V1\Rest\PemeriksaanEmg\Service as EMG;
use MedicalRecord\V1\Rest\PemeriksaanRavenTest\Service as RavenTest;
use MedicalRecord\V1\Rest\PemeriksaanEkg\Service as EKG;

class BerkasController extends RPCResource
{
    protected $title = "Berkas";
    protected $penjamin;
    protected $kunjungan;
    protected $pemeriksaan;
    protected $farmasi;
    protected $pendukung;
    protected $tagihanPendaftaran;
    protected $penjaminTagihan;

    protected $hasilPa;
    protected $sst;

    protected $eeg;
    protected $emg;
    protected $raventest;
    protected $ekg;

	public function __construct($controller) {
        $this->authType = self::AUTH_TYPE_LOGIN;
        $this->penjamin = new PenjaminService(true, [
            'Kelas' => true,
            'Pembayaran' => false,
            'TarifFarmasi' => false,		
            'KAP' => false,
            'JenisPeserta' => true,
            'Pendaftaran' => true,
        ]);
        $this->kunjungan = new KunjunganService(true, [
            'Ruangan' => true,
            'Referensi' => true,
            'Pendaftaran' => true,
            'RuangKamarTidur' => true,
            'PasienPulang' => true,
            'Pembatalan' => false,
            'Perujuk' => false,
            'Mutasi' => false,
            'RujukanKeluar' => true,
            'DPJP' => true,
            'DPJPPenjaminRs' => false
        ]);
        $this->pemeriksaan = new TindakanMedisService(true, [
            "Kunjungan" => false
        ]);
        $this->farmasi = new FarmasiService();
        $this->pendukung = new DokumenPendukungService();
        $this->tagihanPendaftaran = new TagihanPendaftaranService(false);
        $this->penjaminTagihan = new PenjaminTagihanService();

        $this->hasilPa = new HasilPaService();
        $this->sst = new HasilEvaluasiSST();

        $this->eeg = new EEG(false);
        $this->emg = new EMG(false);
        $this->raventest = new RavenTest(false);
        $this->ekg = new EKG(false);
    }

    public function get($id) {
        $datas = $this->penjamin->load([
            "NOMOR" => $id
        ]);
        $data = null;
        $result = [
			"status" => 404,
			"success" => false,
			"total" => 0,
			"data" => null,
			"detail" => $this->title." tidak ditemukan"
        ];
        if(count($datas) > 0) {
            foreach($datas as $d) {
                $pdftrn = $d["REFERENSI"]["PENDAFTARAN"]; 
                if ($pdftrn["STATUS"] == 1 && $this->isAllowPrivilage('2401010301')) $result["detail"] = $this->title." belum final";
                else if(($pdftrn["STATUS"] == 2 && $this->dataAkses->JNS == 2) || 
                    (($pdftrn["STATUS"] == 2 || $pdftrn["STATUS"] == 1) && $this->dataAkses->JNS == 1)) {
                    $tps = $this->tagihanPendaftaran->load([
                        "PENDAFTARAN" => $pdftrn["NOMOR"],
                        "UTAMA" => 1,
                        "STATUS" => 1
                    ]);
                    if(count($tps) > 0) {
                        $d["REFERENSI"]["TAGIHAN"] = [
                            "NOMOR" => $tps[0]["TAGIHAN"]
                        ];
                        $pts = $this->penjaminTagihan->load([
                            "TAGIHAN" => $tps[0]["TAGIHAN"],
                            "PENJAMIN" => $d["JENIS"]
                        ]);
                        if(count($pts) > 0) {
                            if(isset($pts[0]["REFERENSI"]["KELAS_KLAIM"])) $d["REFERENSI"]["KELAS_KLAIM"] = $pts[0]["REFERENSI"]["KELAS_KLAIM"];
                        }
                    }
                    $data = $d;
                    $result["status"] = 200;
                    $result["success"] = true;
                    $result["total"] = 1;
                    $result["data"] = $data;
                    $result["detail"] = $this->title." ditemukan";
                } else {
                    if($pdftrn["STATUS"] == 1 && $this->dataAkses->JNS == 2) $result["detail"] = $this->title."belum final tagihan";
                   
                }
            }
        }
		
		return $result;
    }

    public function kunjunganAction() {
        $params = (array) $this->getRequest()->getQuery();
        if(isset($params["page"])) unset($params["page"]);
        if(isset($params["limit"])) {
            if($params["limit"] > 1000) $params["limit"] = 1000;
        }

        if(!isset($params["STATUS"])) $params["STATUS"] = 2;

        if(isset($params["TAGIHAN"])) {
            if(isset($params["NOPEN"])) unset($params["NOPEN"]);
            $tps = $this->tagihanPendaftaran->load([
                "TAGIHAN" => $params["TAGIHAN"],
                "STATUS" => 1
            ], ['*'], ['UTAMA DESC']);
            $nopens = [];
            if(count($tps) > 0) {
                foreach($tps as $t) {
                    $nopens[] = $t["PENDAFTARAN"];
                }

                if(count($nopens) > 0) $params[] = new \Laminas\Db\Sql\Predicate\In("kunjungan.NOPEN", $nopens);
            }

            if(count($nopens) == 0) return [
                "status" => 404,
                "success" => false,
                "detail" => "Data kunjungan tidak ditemukan"
            ];
        } else {
            if(!isset($params["NOPEN"])) return [
                "status" => 412,
                "success" => false,
                "detail" => "Silahkan masukkan parameter NOPEN"
            ];
        }

        $data = null;
        $order = ["MASUK"];
		if (isset($params["sort"])) {
			$orders = json_decode($params["sort"]);
			if(is_array($orders)) {
			} else {
				$orders->direction = strtoupper($orders->direction);
				$order = array($orders->property." ".($orders->direction == "ASC" || $orders->direction == "DESC" ? $orders->direction : ""));
			}
			unset($params["sort"]);
		}
		
		$total = $this->kunjungan->getRowCount($params);
		if($total > 0) {
            $data = $this->kunjungan->load($params, ['*'], $order);

            foreach($data as &$entity) {
                $entity['REFERENSI']["HASIL_PEMERIKSAAN"] = [];
                if($entity['JENIS_KUNJUNGAN'] == 4) {
                    $hasilPa = $this->hasilPa->load(['KUNJUNGAN' => $entity['NOMOR'], "STATUS" => 1]);
                    $entity['REFERENSI']['HASIL_PA'] = $hasilPa;

                    $sst = $this->sst->load(['KUNJUNGAN' => $entity['NOMOR'], "STATUS" => 1]);
                    if(count($sst) > 0) $entity['REFERENSI']['HASIL_SST'] = $sst[0];
                }

                $pemeriksaan = $this->eeg->load(['KUNJUNGAN' => $entity['NOMOR'], "STATUS" => 1]);
                if(count($pemeriksaan) > 0) $entity['REFERENSI']["HASIL_PEMERIKSAAN"][] = [
                    "TITLE" => "EEG",
                    "NAME" => "mr.CetakHasilEEG",
                    "PARAMETER" => [
                        "PKUNJUNGAN" => $entity['NOMOR']
                    ],
                    "DOCUMENT_STORAGE" => [
                        "REF_ID" => $pemeriksaan[0]["ID"],
                        "DOCUMENT_DIRECTORY_ID" => 18
                    ]
                ];
                $pemeriksaan = $this->emg->load(['KUNJUNGAN' => $entity['NOMOR'], "STATUS" => 1]);
                if(count($pemeriksaan) > 0) $entity['REFERENSI']["HASIL_PEMERIKSAAN"][] = [
                    "TITLE" => "EMG",
                    "NAME" => "mr.CetakHasilEMG",
                    "PARAMETER" => [
                        "PKUNJUNGAN" => $entity['NOMOR']
                    ],
                    "DOCUMENT_STORAGE" => [
                        "REF_ID" => $pemeriksaan[0]["ID"],
                        "DOCUMENT_DIRECTORY_ID" => 17
                    ]
                ];
                $pemeriksaan = $this->raventest->load(['KUNJUNGAN' => $entity['NOMOR'], "STATUS" => 1]);
                if(count($pemeriksaan) > 0) $entity['REFERENSI']["HASIL_PEMERIKSAAN"][] = [
                    "TITLE" => "Raven Test",
                    "NAME" => "mr.CetakHasilRavenTest",
                    "PARAMETER" => [
                        "PKUNJUNGAN" => $entity['NOMOR']
                    ],
                    "DOCUMENT_STORAGE" => [
                        "REF_ID" => $pemeriksaan[0]["ID"],
                        "DOCUMENT_DIRECTORY_ID" => 19
                    ]
                ];
                $pemeriksaan = $this->ekg->load(['KUNJUNGAN' => $entity['NOMOR'], "STATUS" => 1]);
                if(count($pemeriksaan) > 0) $entity['REFERENSI']["HASIL_PEMERIKSAAN"][] = [
                    "TITLE" => "EKG",
                    "NAME" => "mr.CetakHasilEkg",
                    "PARAMETER" => [
                        "PKUNJUNGAN" => $entity['NOMOR']
                    ],
                    "DOCUMENT_STORAGE" => [
                        "REF_ID" => $pemeriksaan[0]["ID"],
                        "DOCUMENT_DIRECTORY_ID" => 20
                    ]
                ];
            }
        }
		
		return [
			"status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => "Kunjungan ".($total > 0 ? " ditemukan" : " tidak ditemukan")
        ];
    }

    public function pemeriksaanAction() {
        $params = (array) $this->getRequest()->getQuery();
        if(isset($params["page"])) unset($params["page"]);
        if(isset($params["limit"])) {
            if($params["limit"] > 1000) $params["limit"] = 1000;
        }

        if(!isset($params["STATUS"])) $params["STATUS"] = 1;

        if(!isset($params["KUNJUNGAN"])) return [
            "status" => 412,
            "success" => false,
            "detail" => "Silahkan masukkan parameter KUNJUNGAN"
        ];

        $data = null;
        $order = ["TANGGAL"];
		if (isset($params["sort"])) {
			$orders = json_decode($params["sort"]);
			if(is_array($orders)) {
			} else {
				$orders->direction = strtoupper($orders->direction);
				$order = array($orders->property." ".($orders->direction == "ASC" || $orders->direction == "DESC" ? $orders->direction : ""));
			}
			unset($params["sort"]);
		}
		
		$total = $this->pemeriksaan->getRowCount($params);
		if($total > 0) $data = $this->pemeriksaan->load($params, ['*'], $order);
		
		return [
			"status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => "Pemeriksaan / Tindakan ".($total > 0 ? " ditemukan" : " tidak ditemukan")
        ];
    }

    public function farmasiAction() {
        $params = (array) $this->getRequest()->getQuery();
        if(isset($params["page"])) unset($params["page"]);
        if(isset($params["limit"])) {
            if($params["limit"] > 1000) $params["limit"] = 1000;
        }

        if(!isset($params["STATUS"])) $params["STATUS"] = 2;

        if(!isset($params["KUNJUNGAN"])) return [
            "status" => 412,
            "success" => false,
            "detail" => "Silahkan masukkan parameter KUNJUNGAN"
        ];

        $data = null;
        $order = ["TANGGAL"];
		if (isset($params["sort"])) {
			$orders = json_decode($params["sort"]);
			if(is_array($orders)) {
			} else {
				$orders->direction = strtoupper($orders->direction);
				$order = array($orders->property." ".($orders->direction == "ASC" || $orders->direction == "DESC" ? $orders->direction : ""));
			}
			unset($params["sort"]);
		}
		
		$total = $this->farmasi->getRowCount($params);
		if($total > 0) $data = $this->farmasi->load($params, ['*'], $order);
		
		return [
			"status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => "Data farmasi ".($total > 0 ? " ditemukan" : " tidak ditemukan")
        ];
    }

    public function LaporanAction() {
        $params = (array) $this->getRequest()->getQuery();
       
        if(!isset($params["KUNJUNGAN"]) || !isset($params["TINDAKAN"])) {
            return [
                "status" => 412,
                "success" => false,
                "detail" => "Silahkan masukkan parameter KUNJUNGAN dan TINDAKAN"
            ];
        }

        $result = $this->pemeriksaan->execute("
        SELECT r.ID
            FROM medicalrecord.operasi r,
                 medicalrecord.operasi_di_tindakan ot
        WHERE r.`STATUS` = 2
            AND r.KUNJUNGAN = (?)
            AND ot.OPERASI_ID = r.ID
            AND ot.TINDAKAN_MEDIS = (?)
            AND ot.`STATUS` = 1", [$params["KUNJUNGAN"], $params["TINDAKAN"]]);
		if(count($result) > 0) {
            return [
                "status" => 200,
                "success" => true,
                "data" => $result[0]["ID"],
                "detail" => "Data di temukan"
            ];
		}
		
		return [
			"status" => 404,
			"success" => false,
			"data" => null,
			"detail" => "Laporan tidak ditemukan"
        ];
    }

    public function daftarDokumenPendukungAction() {
        $params = (array) $this->getRequest()->getQuery();
        if(isset($params["page"])) unset($params["page"]);

        if(!isset($params["status"])) $params["status"] = 1;

        if(!isset($params["no_klaim"])) return [
            "status" => 412,
            "success" => false,
            "detail" => "Silahkan masukkan parameter no_klaim"
        ];

        $data = null;
		$data = $this->pendukung->load($params, ["id", "no_klaim", "file_id", "file_class", "file_name", "file_size", "file_type", "document_id", "kirim_bpjs"]);
		$total = count($data);
		return [
			"status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => "Daftar Dokumen Pendukung ".($total > 0 ? " ditemukan" : " tidak ditemukan")
        ];
    }

    public function dokumenPendukungAction() {
        $id = $this->params()->fromRoute('id', 0);
        $data = $this->pendukung->load([
            "id" => $id
        ], ["file_name", "file_type", "file_content"]);
        if(count($data) == 0) {
            return [
                "status" => 404,
                "success" => false,
                "total" => 0,
                "data" => null,
                "detail" => "Dokumen Pendukung tidak ditemukan"
            ];
        }
        $data = $data[0];
        $fs = explode(".", $data["file_name"]);
        return $this->downloadDocument($data["file_content"], $data["file_type"], $fs[1], $fs[0], false);
    }
}
