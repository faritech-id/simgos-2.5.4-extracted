<?php
namespace Kemkes\RSOnline\V1\Rest\Pasien;

use DBService\SystemArrayObject;

class PasienEntity extends SystemArrayObject
{
	protected $fields = [
		"noc" => 1
        , "nomr" => 1
        , "initial" => 1
        , "nama_lengkap" => 1
        , "tglmasuk" => 1
        , "gender" => 1
        , "birthdate" => 1
        , "kewarganegaraan" => 1
        , "sumber_penularan" => 1
        , "kecamatan" => 1
        , "tglkeluar" => 1
        , "status_keluar" => 1
        , "tgl_lapor" => 1
        , "status_rawat" => 1
        , "status_isolasi" => 1
        , "email" => 1
        , "notelp" => 1
        , "sebab_kematian" => 1
        , "jenis_pasien" => 1
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