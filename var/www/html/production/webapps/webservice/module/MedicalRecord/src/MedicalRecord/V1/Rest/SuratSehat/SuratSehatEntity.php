<?php
namespace MedicalRecord\V1\Rest\SuratSehat;
use DBService\SystemArrayObject;

class SuratSehatEntity extends SystemArrayObject
{
    protected $fields = [
		"ID"=>1
		, "KUNJUNGAN"=>1
		, "NOMOR"=>1
        , "TANGGAL"=>1
		, "ATAS_PERMINTAAN"=>1
		, "HASIL_PEMERIKSAAN"=>1
        , "KETERANGAN"=>1
        , "DIBUAT_TANGGAL"=>1
		, "OLEH"=>1
		, "STATUS"=>1
    ];
}