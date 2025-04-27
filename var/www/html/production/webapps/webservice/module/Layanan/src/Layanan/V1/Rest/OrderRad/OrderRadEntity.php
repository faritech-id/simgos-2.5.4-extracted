<?php
namespace Layanan\V1\Rest\OrderRad;
use DBService\SystemArrayObject;

class OrderRadEntity extends SystemArrayObject
{
	protected $fields = [
		'NOMOR'=>1, 
		'KUNJUNGAN'=>1, 
		'TANGGAL'=>1, 
		'DOKTER_ASAL'=>1, 
		'TUJUAN'=>1, 
		'CITO'=>1, 
		'ALASAN'=>1, 
		'KETERANGAN'=>1,
		'STATUS_PUASA_PASIEN'=>1,
		'STATUS_ALERGI'=>1,
		'STATUS_KEHAMILAN'=>1,
		'OLEH'=>1,
		'STATUS'=>1
	];
}
