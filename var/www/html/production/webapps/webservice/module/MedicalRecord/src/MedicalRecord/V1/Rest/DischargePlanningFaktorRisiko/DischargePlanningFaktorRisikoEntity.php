<?php
namespace MedicalRecord\V1\Rest\DischargePlanningFaktorRisiko;

use DBService\SystemArrayObject;

class DischargePlanningFaktorRisikoEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1
		, "KUNJUNGAN"=>1
		, "PASIEN_TINGGAL_SENDIRI"=>1
		, "PASIEN_KHAWATIR_KETIKA_DIRUMAH"=>1
		, "PASIEN_TAK_ADA_YANG_MERAWAT"=>1
		, "PASIEN_DILANTAI_ATAS"=>1
		, "PERAWATAN_LANJUTAN_PASIEN"=>1
		, "PENGAJUAN_PENDAMPINGAN_PASIEN"=>1
		, "REASSESSMENT"=>1
		, "TANGGAL"=>1
		, "TANGGAL_REASSESSMENT"=>1
		, "USER"=>1
		, "USER_REASSESSMENT"=>1
		, "STATUS"=>1
    ];
}