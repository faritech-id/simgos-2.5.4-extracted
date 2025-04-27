<?php
namespace MedicalRecord\V1\Rest\RiwayatPemberianObat;

use DBService\SystemArrayObject;

class RiwayatPemberianObatEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1
		, "KUNJUNGAN"=>1
		, "OBAT"=>1
		, "DOSIS"=>1
		, "FREKUENSI"=>1
		, "RUTE"=>1
		, "LAMA_PENGGUNAAN"=>1
		, "TANGGAL"=>1
		, "OLEH"=>1
		, "STATUS"=>1
    ];
}
