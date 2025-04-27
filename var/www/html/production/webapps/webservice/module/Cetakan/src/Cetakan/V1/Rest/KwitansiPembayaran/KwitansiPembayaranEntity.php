<?php
namespace Cetakan\V1\Rest\KwitansiPembayaran;
use DBService\SystemArrayObject;

class KwitansiPembayaranEntity extends SystemArrayObject
{
	protected $fields = [
		'ID'=>1,
		'TAGIHAN'=>1, 
		'TANGGAL'=>1, 
		'NOMOR'=>1, 
		'TUNAI'=>1, 
		'JENIS_LAYANAN_ID'=>1,
		'NAMA'=>1,
		'OLEH'=>1, 
		'STATUS'=>1
	];
}