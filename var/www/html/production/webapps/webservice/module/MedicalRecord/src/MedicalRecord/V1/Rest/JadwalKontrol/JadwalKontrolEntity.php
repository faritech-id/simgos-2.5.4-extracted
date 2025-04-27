<?php
namespace MedicalRecord\V1\Rest\JadwalKontrol;

use DBService\SystemArrayObject;

class JadwalKontrolEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1
		, "KUNJUNGAN"=>1
		, "NOMOR"=>1
		, "NOMOR_REFERENSI"=>1
		, "NOMOR_ANTRIAN"=>1
		, "NOMOR_BOOKING"=>1
		, "TUJUAN"=>[
			"DESCRIPTION" => "Tujuan Spesialistik",
			"REQUIRED" => true,
		]
		, "DOKTER"=>[
			"DESCRIPTION" => "Dokter",
			"REQUIRED" => true,
		]
		, "DESKRIPSI"=>1
		, "RUANGAN"=>[
			"DESCRIPTION" => "Ruangan Tujuan",
			"REQUIRED" => true,
		]
		, "BERULANG" =>1
        , "TANGGAL"=>[
			"DESCRIPTION" => "Tanggal Kontrol",
			"REQUIRED" => true,
		]
        , "JAM"=>1
        , "DIBUAT_TANGGAL"=>1
		, "OLEH"=>1
		, "STATUS"=>1
    ];

}