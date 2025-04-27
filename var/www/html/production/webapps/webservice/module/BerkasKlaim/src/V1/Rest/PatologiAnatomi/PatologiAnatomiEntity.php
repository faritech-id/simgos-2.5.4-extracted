<?php
namespace BerkasKlaim\V1\Rest\PatologiAnatomi;
use DBService\SystemArrayObject;

class PatologiAnatomiEntity extends SystemArrayObject
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
