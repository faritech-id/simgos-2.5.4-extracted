<?php
namespace MedicalRecord\V1\Rest\Diagnosis;
use DBService\SystemArrayObject;

class DiagnosisEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1
		, "KUNJUNGAN"=>1
		, "DIAGNOSIS"=>1
		, "TANGGAL"=>1
		, "OLEH"=>1
		, "STATUS"=>1
    ];
}
