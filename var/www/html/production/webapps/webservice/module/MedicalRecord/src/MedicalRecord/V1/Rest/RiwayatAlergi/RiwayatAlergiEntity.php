<?php
namespace MedicalRecord\V1\Rest\RiwayatAlergi;
use DBService\SystemArrayObject;

class RiwayatAlergiEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1
		, "KUNJUNGAN"=>1
		, "JENIS"=>1
		, "DESKRIPSI"=>1
		, "TANGGAL"=>1
		, "KODE_REFERENSI" => 1
		, "OLEH"=>1
		, "STATUS"=>1
	];
}
