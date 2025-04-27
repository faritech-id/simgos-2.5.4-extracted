<?php
namespace MedicalRecord\V1\Rest\Resume;

use DBService\SystemArrayObject;

class ResumeEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1
		, "NOPEN"=>1
		, "ANAMNESIS"=>1
		, "RPP"=>1
		, "RPS"=>1
		, "KELUHAN_UTAMA"=>1
		, "TANDA_VITAL"=>1
		, "RENCANA_TERAPI"=>1
		, "EDUKASI_EMERGENCY"=>1
		, "JADWAL_KONTROL"=>1
		, "RENCANA_DIET"=>1
        , "DIAGNOSA_PROSEDUR"=>1
        , "DIAGNOSA_FARMASI"=>1
        , "HASIL_LAB"=>1
		, "HASIL_RAD"=>1
		, "HASIL_EKG"=>1
		, "INDIKASI_RAWAT_INAP"=>1
		, "ALERGI_REAKSI_OBAT"=>1
		, "DESKRIPSI_HASIL_LAB"=>1
		, "DESKRIPSI_HASIL_RAD"=>1
		, "DESKRIPSI_HASIL_PENUNJANG_LAINYA"=>1
		, "DESKRIPSI_KONSUL"=>1
		, "TANGGAL"=>1
		, "OLEH"=>1
		, "STATUS"=>1
    ];
}