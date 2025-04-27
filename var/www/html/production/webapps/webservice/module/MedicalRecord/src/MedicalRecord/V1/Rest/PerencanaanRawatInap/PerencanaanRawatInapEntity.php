<?php
namespace MedicalRecord\V1\Rest\PerencanaanRawatInap;
use DBService\SystemArrayObject;
class PerencanaanRawatInapEntity extends SystemArrayObject
{
    protected $fields = [
		"ID"=>1
		, "KUNJUNGAN"=>1
		, "NOMOR"=>1
		, "NOMOR_REFERENSI"=>1
		, "JENIS_RUANG_PERAWATAN"=>1     
		, "JENIS_PERAWATAN"=>1 
		, "INDIKASI"=>1
		, "DESKRIPSI"=>1
        , "TANGGAL"=>1
        , "DIBUAT_TANGGAL"=>1
		, "DOKTER"=>1
		, "OLEH"=>1
		, "STATUS"=>1
    ];
}
