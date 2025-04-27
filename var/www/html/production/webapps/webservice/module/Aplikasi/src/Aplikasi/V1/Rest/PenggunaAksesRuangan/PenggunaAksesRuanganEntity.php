<?php
namespace Aplikasi\V1\Rest\PenggunaAksesRuangan;
use DBService\SystemArrayObject;

class PenggunaAksesRuanganEntity extends SystemArrayObject
{
	protected $fields = [
		'ID' => 1, 
		'TANGGAL' => 1, 
		'PENGGUNA' => [
            "DESCRIPTION" => "Id Pengguna",
			"REQUIRED" => true
		],
		'RUANGAN' => [
            "DESCRIPTION" => "Id Ruangan",
			"REQUIRED" => true
		],  
		'DIBERIKAN_OLEH' => 1, 
		'STATUS' => 3
	];
}
