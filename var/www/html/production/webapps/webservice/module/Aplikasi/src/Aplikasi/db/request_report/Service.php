<?php
namespace Aplikasi\db\request_report;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;
use Aplikasi\V1\Rest\Pengguna\PenggunaService;

class Service extends DBService {
	public function __construct() {
	    $this->config["entityName"] = "\\Aplikasi\\db\\request_report\\Entity";
	    $this->config["autoIncrement"] = false;
		$this->config["generateUUID"] = true;
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("request_report", "laporan"));
		$this->entity = new Entity();

		$this->pengguna = new PenggunaService();
    }

	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);

		foreach($data as &$entity) {
			if(!empty($entity["DIBUAT_OLEH"])) {
                $result = $this->pengguna->getPegawai($entity["DIBUAT_OLEH"]);
                if($result) $entity["REFERENSI"]["DIBUAT_OLEH"] = [
                    "ID" => $result["ID"],
                    "NIP" => $result["NIP"],
                    "GELAR_DEPAN" => $result["GELAR_DEPAN"],
                    "NAMA" => $result["NAMA"],
                    "GELAR_BELAKANG" => $result["GELAR_BELAKANG"],
                    "NIK" => $this->getNikPegawai($result)
                ];
            }

            if(!empty($entity["DIUBAH_OLEH"])) {
                $result = $this->pengguna->getPegawai($entity["DIUBAH_OLEH"]);
                if($result) $entity["REFERENSI"]["DIUBAH_OLEH"] = [
					"ID" => $result["ID"],
					"NIP" => $result["NIP"],
                    "GELAR_DEPAN" => $result["GELAR_DEPAN"],
                    "NAMA" => $result["NAMA"],
                    "GELAR_BELAKANG" => $result["GELAR_BELAKANG"],
                    "NIK" => $this->getNikPegawai($result)
                ];
            }

            if(!empty($entity["TTD_OLEH"])) {
                $result = $this->pengguna->getPegawai($entity["TTD_OLEH"]);
                if($result) $entity["REFERENSI"]["TTD_OLEH"] = [
					"ID" => $result["ID"],
					"NIP" => $result["NIP"],
                    "GELAR_DEPAN" => $result["GELAR_DEPAN"],
                    "NAMA" => $result["NAMA"],
                    "GELAR_BELAKANG" => $result["GELAR_BELAKANG"],
                    "NIK" => $this->getNikPegawai($result)
                ];
            }
		}	

		return $data;
	}

    private function getNikPegawai($pegawai) {
        $nomor = "";
        if($pegawai) {
            if(isset($pegawai["KARTU_IDENTITAS"])) {
                foreach($pegawai["KARTU_IDENTITAS"] as $kartu) {
                    if($kartu["JENIS"] == 1) $nomor = $kartu["NOMOR"];
                }
            }
        }
        return $nomor;
    }

    public function hapus($params = []) {
		$this->table->delete($params);
		return true;
	}
}