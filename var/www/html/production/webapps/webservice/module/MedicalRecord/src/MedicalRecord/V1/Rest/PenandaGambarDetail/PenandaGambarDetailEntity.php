<?php
namespace MedicalRecord\V1\Rest\PenandaGambarDetail;
use DBService\SystemArrayObject;

class PenandaGambarDetailEntity extends SystemArrayObject
{
    protected $fields = [
		"ID"=>1
		, "NOMOR"=>1
		, "PENANDA"=>1
		, "TIPE"=>1
		, "NAMA_TIPE"=>1
		, "KORDINATX"=>1
		, "KORDINATY"=>1
        , "WARNA"=>1
		, "PATH"=>1
		, "WARNA_LATAR"=>1
		, "KETERANGAN"=>1
		, "TANGGAL"=>1
		, "OLEH"=>1
		, "STATUS"=>1
	];
        
}
