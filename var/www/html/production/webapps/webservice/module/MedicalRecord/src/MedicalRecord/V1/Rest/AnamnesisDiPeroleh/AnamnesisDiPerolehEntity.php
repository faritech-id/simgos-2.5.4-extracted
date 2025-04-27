<?php
namespace MedicalRecord\V1\Rest\AnamnesisDiPeroleh;

use DBService\SystemArrayObject;

class AnamnesisDiPerolehEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1
		, "KUNJUNGAN"=>1
		, "AUTOANAMNESIS"=>1
		, "ALLOANAMNESIS"=>1
		, "DARI"=>1
		, "TANGGAL"=>1
		, "OLEH"=>1
		, "STATUS"=>1
	];
}