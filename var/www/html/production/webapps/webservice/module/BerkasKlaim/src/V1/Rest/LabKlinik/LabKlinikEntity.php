<?php
namespace BerkasKlaim\V1\Rest\LabKlinik;
use DBService\SystemArrayObject;

class LabKlinikEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1
		, "NORM"=>1
		, "NOSEP"=>1
		, "TANGGAL"=>1
		, "OLEH"=>1
		, "STATUS"=>1
	];
}
