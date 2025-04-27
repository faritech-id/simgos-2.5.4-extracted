<?php
namespace Pembayaran\V1\Rest\PembayaranTagihan;
use DBService\SystemArrayObject;

class PembayaranTagihanEntity extends SystemArrayObject
{
	protected $fields = [
		'NOMOR'=>1,
		'TAGIHAN'=>[
			"REQUIRED" => true,
			"DESCRIPTION" => "Nomor Tagihan"
		],
		'JENIS'=>[
			"REQUIRED" => true,
			"DESCRIPTION" => "Jenis Pembayaran"
		],
		'JENIS_LAYANAN_ID'=>1,
		'PENYEDIA_ID'=>1,
		'TANGGAL'=>1,
		'REKENING_ID'=>1,
		'NO_ID'=>1,
		'NAMA'=>1,
		'REF'=>1,
		'JENIS_KARTU_ID'=>1,
		'BANK_ID'=>1,
		'DESKRIPSI'=>1,
		'TOTAL'=>1,
		'BRIDGE'=>1,
		'TRANSAKSI_KASIR_NOMOR'=>[
			"REQUIRED" => true,
			"DESCRIPTION" => "Nomor Transaksi Kasir"
		],
		'TANGGAL_DIBUAT'=>1,
		'BATAS_WAKTU'=>1,
		'OLEH'=>1,
		'DIUBAH_TANGGAL'=>1,
		'DIUBAH_OLEH' =>1,
		'STATUS'=>1
	];
}
