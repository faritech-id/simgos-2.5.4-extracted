<?php
namespace LISService\vanslab\dbservice\order_lab;
use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		'asal_lab'=>1, // 1=Lab Sentral,2=Lab IGD,3=Lab PCC,4=Lab PJT
		'kode_asal_lab'=>1, // Penambahan field (not default)
		'nama_asal_lab'=>1, // Penambahan field (not default)
		'no_lab'=>1, 
		'no_registrasi'=>1,
		'no_rm'=>1,
		'tgl_order'=>1,
		'nama_pas'=>1,
		'jenis_kel'=>1, // 1=Laki-laki, 0=Perempuan
		'tgl_lahir'=>1, 
		'usia'=>1, 
		'alamat'=>1, 
		'kode_dok_kirim'=>1, 
		'nama_dok_kirim'=>1, // Nama Dokter
		'kode_ruang'=>1, 
		'nama_ruang'=>1, // Nama Asal ruangan Di Register RS
		'kode_cara_bayar'=>1, 
		'cara_bayar'=>1,
		'ket_klinis'=>1, // Diagnosa Awals
		'test'=>1, // Kode Test/Tindakan
		'order_item_id'=>1, // Penambahan field (not default)
		'order_item_name'=>1, // Penambahan field (not default)
		'waktu_kirim'=>1, 
		'prioritas'=>1, 
		'jns_rawat'=>1, // 1=RJ,2=RI,6=RDarurat,3=Konsul RJ,4=Konsul RI,7=Konsul RD
		'dok_jaga'=>1, 
		'batal'=>1, 
		'status'=>1
	];
}