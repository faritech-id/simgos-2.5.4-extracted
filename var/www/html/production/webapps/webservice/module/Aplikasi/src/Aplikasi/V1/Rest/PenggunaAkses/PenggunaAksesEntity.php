<?php
namespace Aplikasi\V1\Rest\PenggunaAkses;
use DBService\SystemArrayObject;

class PenggunaAksesEntity extends SystemArrayObject
{
	protected $fields = [
		'ID' => 1, 
		'PENGGUNA' => [
            "DESCRIPTION" => "Id Pengguna",
			"REQUIRED" => true
		], 
		'GROUP_PENGGUNA_AKSES_MODULE' => [
            "DESCRIPTION" => "Id Grup Pengguna Akses Modul",
			"REQUIRED" => true
		], 
		'STATUS' => 1
	];
}
