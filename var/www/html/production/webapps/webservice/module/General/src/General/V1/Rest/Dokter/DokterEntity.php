<?php
namespace General\V1\Rest\Dokter;
use DBService\SystemArrayObject;

class DokterEntity extends SystemArrayObject
{
	protected $fields = [
		'ID' => 1, 
		'NIP' => [
			"DESCRIPTION" => "NIP",
			"REQUIRED" => true
		], 
		'STATUS' => 1
	];
}
