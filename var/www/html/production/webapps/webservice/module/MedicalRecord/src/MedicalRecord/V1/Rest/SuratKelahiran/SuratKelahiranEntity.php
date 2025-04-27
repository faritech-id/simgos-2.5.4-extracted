<?php
namespace MedicalRecord\V1\Rest\SuratKelahiran;
use DBService\SystemArrayObject;

class SuratKelahiranEntity  extends SystemArrayObject
{
    protected $fields = [
		"ID"=>1
		, "KUNJUNGAN"=>1
		, "NOMOR"=>1
		, "TANGGAL"=>1
		, "JAM"=>1
		, "BERAT"=>1
		, "PANJANG"=>1
		, "NORM_IBU"=>1
        , "IBU"=>1
		, "BAPAK"=>1
		, "DPJP"=>1
		, "BIDAN"=>1
		, "INDEX_MASSA_TUBUH"=>1
		, "LINGKAR_KEPALA"=>1
		, "KEMBAR"=>1
		, "KELAHIRAN_NORMAL"=>1
		, "JENIS_PERSALINAN"=>1
		, "TINDAKAN"=>1
		, "OLEH"=>1
		, "STATUS"=>1
    ];
}
