<?php
namespace MedicalRecord\V1\Rest\PenilaianNyeri;
use DBService\SystemArrayObject;

class PenilaianNyeriEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1
		, "KUNJUNGAN"=>1
		, "NYERI"=>1
		, "ONSET"=>1
		, "SKALA"=>1
		, "METODE"=>1
		, "PENCETUS"=>1
		, "GAMBARAN"=>1
		, "DURASI"=>1
		, "LOKASI"=>1
		, "TANGGAL"=>1
		, "OLEH"=>1
		, "STATUS"=>1
    ];
}
