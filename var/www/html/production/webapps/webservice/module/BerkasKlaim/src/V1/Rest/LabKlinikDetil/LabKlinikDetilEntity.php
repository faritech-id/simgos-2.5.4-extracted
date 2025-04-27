<?php
namespace BerkasKlaim\V1\Rest\LabKlinikDetil;
use DBService\SystemArrayObject;

class LabKlinikDetilEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1
		, "LAB_KLINIK"=>1
		, "HASIL_LAB"=>1
		, "TINDAKAN_MEDIS"=>1
		, "STATUS"=>1
	];
}
