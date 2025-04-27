<?php
namespace BerkasKlaim\V1\Rest\RadiologiDetil;
use DBService\SystemArrayObject;

class RadiologiDetilEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1
		, "RADIOLOGI"=>1
		, "HASIL_RAD"=>1
		, "STATUS"=>1
	];
}
