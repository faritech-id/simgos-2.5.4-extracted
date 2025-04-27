<?php
namespace MedicalRecord\V1\Rest\CPPT;

use DBService\SystemArrayObject;

class CPPTEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1
		, "KUNJUNGAN"=>1
		, "TANGGAL"=>1
		, "SUBYEKTIF"=>1
		, "OBYEKTIF"=>1
		, "ASSESMENT"=>1
		, "PLANNING"=>1
		, "INSTRUKSI" =>1
		, "TULIS" =>1
		, "JENIS"=>1
		, "TENAGA_MEDIS"=>1
		, "STATUS_SBAR" => 1
		, "STATUS_TBAK" => 1
		, "BACA" => 1
		, "KONFIRMASI" => 1
		, "RENCANA_PULANG" => 1
		, "TANGGAL_RENCANA_PULANG" => 1
		, "DOKTER_TBAK_OR_SBAR" => 1
		, "SUB_DEVISI" => 1
		, "OLEH"=>1
		, "STATUS"=>1
	];
}
