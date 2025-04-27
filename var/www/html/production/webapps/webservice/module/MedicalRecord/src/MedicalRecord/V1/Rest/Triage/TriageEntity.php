<?php
namespace MedicalRecord\V1\Rest\Triage;

use DBService\SystemArrayObject;

class TriageEntity extends SystemArrayObject
{
    protected $fields = [
		"ID"=>1
        , "NORM"=>1
        , "NOPEN"=>1
        , "KUNJUNGAN"=>1
		, "NIK"=>1
		, "NAMA"=>1
		, "TANGGAL_LAHIR"=>1
		, "JENIS_KELAMIN"=>1
        , "TANGGAL"=>1
		, "KEDATANGAN"=>1
		, "KASUS"=>1
		, "ANAMNESE"=>1
		, "TANDA_VITAL"=>1
		, "OBGYN"=>1
		, "KEBUTUHAN_KHUSUS"=>1
		, "KATEGORI_PEMERIKSAAN"=>1
		, "RESUSITASI"=>1
		, "EMERGENCY"=>1
		, "URGENT"=>1
		, "LESS_URGENT"=>1
		, "NON_URGENT"=>1
		, "DOA"=>1
		, "KRITERIA"=>1
		, "HANDOVER"=>1
		, "PLAN"=>1
		, "OLEH"=>1
		, "TANGGAL_FINAL"=>1
		, "STATUS"=>1
    ];
}
