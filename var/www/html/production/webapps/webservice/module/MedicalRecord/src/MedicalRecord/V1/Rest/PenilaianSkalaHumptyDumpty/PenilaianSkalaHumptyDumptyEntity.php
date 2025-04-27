<?php
namespace MedicalRecord\V1\Rest\PenilaianSkalaHumptyDumpty;
use DBService\SystemArrayObject;

class PenilaianSkalaHumptyDumptyEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1
		, "KUNJUNGAN"=>1
		, "UMUR"=>1
		, "JENIS_KELAMIN"=>1
		, "DIAGNOSA"=>1
		, "GANGGUAN_KONGNITIF"=>1
		, "FAKTOR_LINGKUNGAN"=>1
		, "RESPON"=>1
		, "PENGGUNAAN_OBAT"=>1
        , "TANGGAL"=>1
		, "OLEH"=>1
		, "STATUS"=>1
    ];
}
