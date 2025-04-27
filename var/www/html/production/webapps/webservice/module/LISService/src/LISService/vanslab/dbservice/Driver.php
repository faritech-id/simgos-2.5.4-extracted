<?php
namespace LISService\vanslab\dbservice;

use LISService\lis\DriverInterface;
use LISService\vanslab\dbservice\order_lab\Service as OrderService;
use LISService\vanslab\dbservice\hasil_lab\Service as ResultService;
use \Exception;

/**
 * @author admin
 * @version 1.0
 * @created 26-Mar-2016 17.43.00
 */
class Driver implements DriverInterface
{	
	private $order;
	private $result;
	private $fieldStatusResult = "status";
	
	public function __construct()
	{	
		$this->order = new OrderService();	
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
		$result = $this->result->load(
			["hasil_lab.$fieldStatus" => 0, "hasil_lab.kode" => 'U', new \Laminas\Db\Sql\Predicate\Expression("(NOT hasil_lab.his_test_id_order IS NULL OR hasil_lab.his_test_id_order != '')")], 
			[
				"no_lab", "no_registrasi", "no_rm", "tgl_order", 
				"kode_test_his", "kode_test", "his_test_id_order", "nama_test", "flag", "hasil", "unit",
				"nilai_normal", "Created_DT"
			],
			["Created_DT"]
		);
			
		foreach($result as $row) {
			$data[] = [
				'LIS_NO'=>$row['no_lab'],
				'HIS_NO_LAB'=>$row['no_registrasi'],
				'LIS_KODE_TEST'=>$row['kode_test'],
				'LIS_NAMA_TEST'=>utf8_encode($row['nama_test']),
				'LIS_HASIL'=>$row['hasil'],
				'LIS_CATATAN'=>'',
				'LIS_NILAI_NORMAL'=>utf8_encode($row["nilai_normal"]),
				'LIS_FLAG'=>$row['flag'],
				'LIS_SATUAN'=>utf8_encode($row['unit']), 
				'LIS_NAMA_INSTRUMENT'=>'',
				'LIS_TANGGAL'=>$row['Created_DT'], 
				'LIS_USER'=>'',
				'HIS_KODE_TEST'=>$row["his_test_id_order"],
				'REF'=>$row['no_rm'], 
				'VENDOR_LIS'=>$this->getVendorId(),
				'LIS_LOKASI'=>''
			];
		}
		
		return $data;
	}
	
	public function updateStatusResult($data)
	{
		$fieldStatus = $this->fieldStatusResult;
		$params = [
			"no_registrasi" => $data["HIS_NO_LAB"],
			'kode_test' => $data["LIS_KODE_TEST"],
			"$fieldStatus" => "1"
		];
		
		$this->result->simpan($params);
	}

	public function order($params=[])
	{
		if(isset($params) && count($params) > 0) {
			$data = json_decode(json_encode($params));
			$kunjungan = $data->REFERENSI->KUNJUNGAN;
			$pendaftaran = $kunjungan->REFERENSI->PENDAFTARAN;
			$pasien = $pendaftaran->REFERENSI->PASIEN;
			$perujuk = isset($kunjungan->REFERENSI->PERUJUK) ? $kunjungan->REFERENSI->PERUJUK : null;
			$order = isset($data->REFERENSI->ORDER_LAB) ? $data->REFERENSI->ORDER_LAB : false;
			$prioritas = 0;
			$ketKlinis = null;
			$jnsRawats = [
				0 => 0,
				1 => 1,
				2 => 6,
				3 => 2
			];
			$jenisRawat = 0;
			if($order) {
				$prioritas = $order->CITO;
				$ketKlinis = $order->ALASAN;
				$wardId = $order->REFERENSI->KUNJUNGAN->REFERENSI->RUANGAN->ID;
				$wardName = $order->REFERENSI->KUNJUNGAN->REFERENSI->RUANGAN->DESKRIPSI;
				$jenisRawat = $jnsRawats[$order->REFERENSI->KUNJUNGAN->JENIS_KUNJUNGAN];			
			} else {
				$wardId = $kunjungan->REFERENSI->RUANGAN->ID;
				$wardName = $kunjungan->REFERENSI->RUANGAN->DESKRIPSI;				
			}
			$nolab = (int) substr($kunjungan->NOMOR, strlen($kunjungan->NOMOR) - 4);
			$this->order->simpan([
				'asal_lab'=>'',
				'kode_asal_lab'=>$kunjungan->REFERENSI->RUANGAN->ID,
				'nama_asal_lab'=>$kunjungan->REFERENSI->RUANGAN->DESKRIPSI,
				'no_lab'=>$nolab,
				'no_registrasi'=>$kunjungan->NOMOR,
				'no_rm'=>$pasien->NORM,
				'tgl_order'=>$kunjungan->MASUK,
				'nama_pas'=>$pasien->NAMA,
				'jenis_kel'=>$pasien->JENIS_KELAMIN == 2 ? 0 : 1,
				'tgl_lahir'=>$pasien->TANGGAL_LAHIR,
				'usia'=>$pasien->UMUR, 
				'alamat'=>$pasien->ALAMAT,
				'kode_dok_kirim'=>$perujuk ? $perujuk->DOKTER_ASAL : null,
				'nama_dok_kirim'=>$perujuk ? $perujuk->REFERENSI->DOKTER_ASAL->NAMA : null,
				'kode_ruang'=>$wardId,
				'nama_ruang'=>$wardName,
				'kode_cara_bayar'=>$pendaftaran->PENJAMIN->JENIS,
				'cara_bayar'=>$pendaftaran->PENJAMIN->REFERENSI->KAP->REFERENSI->PENJAMIN->DESKRIPSI,
				'ket_klinis'=>$ketKlinis,
				'order_item_id'=>$data->TINDAKAN,
				'order_item_name'=>$data->TINDAKAN_DESKRIPSI,
				'waktu_kirim'=>$data->TANGGAL,
				'prioritas'=>$prioritas,
				'jns_rawat'=>$jenisRawat,
				'dok_jaga'=>null,
				'batal'=>$data->STATUS == 1 ? 0 : 1
			]);
		}
	}

	public function dbStatus() {
		$fieldStatus = $this->fieldStatusResult;
		$this->result->load(["hasil_lab.$fieldStatus" => 0, "hasil_lab.kode" => 'U']);
	}
	
	public function getVendorId(){
		return 3;
	}
}