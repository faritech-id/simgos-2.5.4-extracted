<?php
namespace General\V1\Rest\DokterSMF;
use DBService\SystemArrayObject;

class DokterSMFEntity extends SystemArrayObject
{
	protected $fields = [
		'ID' => 1,
		'TANGGAL' => 1,
		'DOKTER' => [
			"DESCRIPTION" => "Dokter",
			"REQUIRED" => true
		],
		'SMF' => [
			"DESCRIPTION" => "Spesialis / Subspesialis",
			"REQUIRED" => true
		],
		'STATUS' => 1
	];
}


