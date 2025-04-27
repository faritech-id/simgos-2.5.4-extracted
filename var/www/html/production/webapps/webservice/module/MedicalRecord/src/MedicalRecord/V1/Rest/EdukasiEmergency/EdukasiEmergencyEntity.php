<?php
namespace MedicalRecord\V1\Rest\EdukasiEmergency;

use DBService\SystemArrayObject;

class EdukasiEmergencyEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1
		, "KUNJUNGAN"=>1
		, "EDUKASI"=>1
		, "KEMBALI_KE_UGD"=>1
		, "TANGGAL"=>1
		, "OLEH"=>1
		, "STATUS"=>1
    ];
}
