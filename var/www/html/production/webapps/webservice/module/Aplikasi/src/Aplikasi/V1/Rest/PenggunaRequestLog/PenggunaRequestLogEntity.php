<?php
namespace Aplikasi\V1\Rest\PenggunaRequestLog;

use DBService\SystemArrayObject;

class PenggunaRequestLogEntity extends SystemArrayObject
{
    protected $fields = [
		"ID"=>1, 
		"PENGGUNA"=>1, 
		"TANGGAL_AKSES"=>1,
		"TANGGAL_SELESAI"=>1, 
		"LOKASI_AKSES"=>1,
		"TUJUAN_AKSES"=>1, 
		"REQUEST_URI"=>1
	];
}
