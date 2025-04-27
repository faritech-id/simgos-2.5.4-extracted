<?php
namespace MedicalRecord\V1\Rest\StatusPediatric;
use DBService\SystemArrayObject;

class StatusPediatricEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1
		, "KUNJUNGAN"=>1
		, "STATUS_PEDIATRIC"=>1
		, "TANGGAL"=>1
		, "OLEH"=>1
		, "STATUS"=>1
    ];
}
