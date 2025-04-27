<?php
namespace Kemkes\V2\Rpc\Dashboard;

use DBService\RPCResource;

use Kemkes\V2\Rpc\Kunjungan\Service as KunjunganService;
use Kemkes\V2\Rpc\Indikator\Service as IndikatorService;
use Kemkes\V2\Rpc\Kematian\Service as KematianService;
use Kemkes\V2\Rpc\Rujukan\Service as RujukanService;
use Kemkes\V2\Rpc\Penyakit10Besar\Service as Penyakit10BesarService;
use Kemkes\V2\Rpc\DiagnosaRujukan10Besar\Service as DiagnosaRujukan10BesarService;
use Kemkes\V2\Rpc\GolonganDarah\Service as GolonganDarahService;

use \DateTime;

class DashboardController extends RPCResource
{
    public function __construct($controller) {
        $this->authType = self::AUTH_TYPE_IP_OR_LOGIN;
    }

    public function kunjunganAction() {
        $service = new KunjunganService();
        $datetime = new DateTime();        
        $params = (array) $this->getRequest()->getQuery();
        $tahun = isset($params["TAHUN"]) && !empty($params["TAHUN"]) ? $params["TAHUN"] : $datetime->format("Y");
        $bulan = isset($params["BULAN"]) && !empty($params["BULAN"]) ? str_pad($params["BULAN"], 2, "0", STR_PAD_LEFT) : $datetime->format("m");
        $tgl = "00";
        
        $tglAwal = $tahun."-".$bulan."-01";
        if($bulan == "12") {            
            $tahun++;
            $bulan = "01";
        } else $bulan++;
        $datetime = DateTime::createFromFormat("Y-m-d", $tahun."-".$bulan."-".$tgl);
        $tglAkhir = $datetime->format("Y-m-d");
        $prms[] = new \Laminas\Db\Sql\Predicate\Between("TANGGAL", $tglAwal, $tglAkhir);
        $data = $service->load($prms, ['*'], ['TANGGAL_UPDATED ASC']);
        $total = count($data);
        
        unset($service);
        unset($datetime);
        
        return [
            "status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => $total > 0 ? "Data Kunjungan ditemukan" : "Data Kunjungan tidak ditemukan"
        ];
    }

    public function rujukanAction() {
        $service = new RujukanService();
        $datetime = new DateTime();        
        $params = (array) $this->getRequest()->getQuery();        
        $tahun = isset($params["TAHUN"]) && !empty($params["TAHUN"]) ? $params["TAHUN"] : $datetime->format("Y");
        $bulan = isset($params["BULAN"]) && !empty($params["BULAN"]) ? str_pad($params["BULAN"], 2, "0", STR_PAD_LEFT) : $datetime->format("m");
        $tgl = "00";
        
        $tglAwal = $tahun."-".$bulan."-01";
        if($bulan == "12") {            
            $tahun++;
            $bulan = "01";
        } else $bulan++;
        $datetime = DateTime::createFromFormat("Y-m-d", $tahun."-".$bulan."-".$tgl);
        $tglAkhir = $datetime->format("Y-m-d");
        $prms[] = new \Laminas\Db\Sql\Predicate\Between("TANGGAL", $tglAwal, $tglAkhir);
        $data = $service->load($prms, ['*'], ['TANGGAL_UPDATED ASC']);
        $total = count($data);
        
        unset($service);
        unset($datetime);
        
        return [
            "status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => $total > 0 ? "Data Rujukan ditemukan" : "Data Rujukan tidak ditemukan"
        ];
    }

    public function penyakitRujukan10BesarAction() {        
        $service = new DiagnosaRujukan10BesarService();        
        $params = (array) $this->getRequest()->getQuery();
        $datetime = new DateTime();
        $tahun = isset($params["TAHUN"]) && !empty($params["TAHUN"]) ? $params["TAHUN"] : $datetime->format("Y");
        
        $prms["TAHUN"] = $tahun;
        $prms["JENIS_RUJUKAN"] = isset($params["JENIS"]) && !empty($params["JENIS"]) ? $params["JENIS"] : 1;
        
        $data = $service->load($prms, ['*'], ['TANGGAL_UPDATED ASC']);
        $total = count($data);
        
        unset($service);
        unset($datetime);
        
        return [
            "status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => $total > 0 ? "10 Besar Penyakit Rujukan ditemukan" : "10 Besar Penyakit Rujukan tidak ditemukan"
        ];
    }

    public function indikatorPelayananAction() {        
        $service = new IndikatorService();        
        $params = (array) $this->getRequest()->getQuery();
        $datetime = new DateTime();
        $tahun = isset($params["TAHUN"]) && !empty($params["TAHUN"]) ? $params["TAHUN"] : $datetime->format("Y");
        
        $prms["TAHUN"] = $tahun;
        $prms["JENIS"] = isset($params["JENIS"]) && !empty($params["JENIS"]) ? $params["JENIS"] : 1;
        
        $data = $service->load($prms, ['*'], ['TANGGAL_UPDATED ASC']);
        $total = count($data);
        
        unset($service);
        unset($datetime);
        
        return [
            "status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => $total > 0 ? "Indikator Pelayanan ditemukan" : "Indikator Pelayanan tidak ditemukan"
        ];
    }

    public function penyakit10BesarAction() {        
        $service = new Penyakit10BesarService();        
        $params = (array) $this->getRequest()->getQuery();
        $datetime = new DateTime();
        $tahun = isset($params["TAHUN"]) && !empty($params["TAHUN"]) ? $params["TAHUN"] : $datetime->format("Y");
        
        $prms["TAHUN"] = $tahun;
        $prms["JENIS_PELAYANAN"] = isset($params["JENIS"]) && !empty($params["JENIS"]) ? $params["JENIS"] : 1;
        
        $data = $service->load($prms, ['*'], ['TANGGAL_UPDATED ASC']);
        $total = count($data);
        
        unset($service);
        unset($datetime);
        
        return [
            "status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => $total > 0 ? "10 Besar Penyakit ditemukan" : "10 Besar Penyakit tidak ditemukan"
        ];
    }

    public function jumlahKematianAction() {        
        $service = new KematianService();        
        $params = (array) $this->getRequest()->getQuery();
        $datetime = new DateTime();
        $tahun = isset($params["TAHUN"]) && !empty($params["TAHUN"]) ? $params["TAHUN"] : $datetime->format("Y");
        
        $prms["TAHUN"] = $tahun;
        
        $data = $service->load($prms, ['*'], ['TANGGAL_UPDATED ASC']);
        $total = count($data);
        
        unset($service);
        unset($datetime);
        
        return [
            "status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => $total > 0 ? "Data Jumlah Kematian ditemukan" : "Data Jumlah Kematian tidak ditemukan"
        ];
    }

    public function golonganDarahAction() {        
        $service = new GolonganDarahService();        
        $params = (array) $this->getRequest()->getQuery();
        $datetime = new DateTime();
        $tahun = isset($params["TAHUN"]) && !empty($params["TAHUN"]) ? $params["TAHUN"] : $datetime->format("Y");
        $bulan = isset($params["BULAN"]) && !empty($params["BULAN"]) ? $params["BULAN"] : $datetime->format("m");
        
        $prms["TAHUN"] = $tahun;
        $prms["BULAN"] = $bulan;
        
        $data = $service->load($prms, ['*'], ['TANGGAL_UPDATED ASC']);
        $total = count($data);
        
        unset($service);
        unset($datetime);
        
        return [
            "status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => $total > 0 ? "Golongan Darah ditemukan" : "Golongan Darah tidak ditemukan"
        ];
    }
}
