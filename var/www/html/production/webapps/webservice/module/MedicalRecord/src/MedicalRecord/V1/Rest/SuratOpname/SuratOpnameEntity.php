<?php
namespace MedicalRecord\V1\Rest\SuratOpname;
use DBService\SystemArrayObject;

class SuratOpnameEntity extends SystemArrayObject
{
    protected $fields = [
		"ID"=>1
		, "KUNJUNGAN"=>1
		, "NOMOR"=>1
        , "TANGGAL"=>1
		, "KETERANGAN"=>1
		, "DIBUAT_TANGGAL"=>1
		, "OLEH"=>1
		, "STATUS"=>1
    ];
}

