<?php
namespace MedicalRecord\V1\Rest\Fungsional;
use DBService\SystemArrayObject;

class FungsionalEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1,
		"KUNJUNGAN"=>1,
		"ALAT_BANTU"=>1,
		"PROTHESA"=>1,
		"CACAT_TUBUH"=>1,
		"TANGGAL"=>1,
		"OLEH"=>1,
		"STATUS"=>1
    ];
}
