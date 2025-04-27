<?php
namespace MedicalRecord\V1\Rest\SuratSakit;

use DBService\SystemArrayObject;

class SuratSakitEntity extends SystemArrayObject
{
    protected $fields = [
		"ID"=>1
		, "KUNJUNGAN"=>1
		, "NOMOR"=>1
        , "TANGGAL"=>1
		, "LAMA"=>1
		, "DESKRIPSI"=>1
        , "DIBUAT_TANGGAL"=>1
		, "OLEH"=>1
		, "STATUS"=>1
    ];
}

