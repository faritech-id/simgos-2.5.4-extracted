<?php
namespace Kemkes\RSOnline\V1\Rest\DiagnosaPasien;

use DBService\SystemArrayObject;

class DiagnosaPasienEntity extends SystemArrayObject
{
	protected $fields = [
		"id" => 1
		, "nomr" => 1
        , "icd" => 1
		, "level" => 1
		, 'baru' => 1
		, 'hapus' => 1
        , 'tgl_kirim' => 1
        , 'kirim' => 1
		, 'response' => 1
		, 'dibuat_oleh' => 1
        , 'tgl_dibuat' => 1
        , 'diubah_oleh' => 1
        , 'tgl_diubah' => 1
	];
}
