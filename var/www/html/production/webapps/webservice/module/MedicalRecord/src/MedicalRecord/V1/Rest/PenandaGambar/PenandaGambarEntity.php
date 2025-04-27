<?php
namespace MedicalRecord\V1\Rest\PenandaGambar;
use DBService\SystemArrayObject;

class PenandaGambarEntity extends SystemArrayObject
{
    protected $fields = [
		"ID"=>1
		, "KUNJUNGAN"=>1
		, "TEMPLATE"=>1
		, "KETERANGAN"=>1
		, "TANGGAL"=>1
		, "FINAL"=>1
		, "OLEH"=>1
		, "STATUS"=>1
	];
}
