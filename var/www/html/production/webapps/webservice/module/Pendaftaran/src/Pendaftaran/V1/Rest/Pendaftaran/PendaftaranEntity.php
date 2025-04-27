<?php
namespace Pendaftaran\V1\Rest\Pendaftaran;
use DBService\SystemArrayObject;

class PendaftaranEntity extends SystemArrayObject
{
	protected $fields = [
		'NOMOR'=>1, 
		'NORM'=>1, 
		'TANGGAL'=>1, 
		'DIAGNOSA_MASUK'=>1, 
		'RUJUKAN'=>1, 
		'PAKET'=>1, 
		'BERAT_BAYI'=>1,
		'PANJANG_BAYI'=>1,
		'CITO'=>1,
		'RESIKO_JATUH'=>1,
		'OLEH'=>1, 
		'STATUS'=>1,
		'LOKASI_DITEMUKAN'=>1,
		'TANGGAL_DITEMUKAN'=>1,
		'JAM_LAHIR'=>1,
		'CONSENT_SATUSEHAT'=>1
	];
}
