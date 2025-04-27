<?php
namespace General\V1\Rest\DokterRuangan;
use DBService\SystemArrayObject;

class DokterRuanganEntity extends SystemArrayObject
{
	protected $fields = [
		'ID' => 1,
		'TANGGAL' => 1,
		'DOKTER' => [
			"DESCRIPTION" => "Dokter",
			"REQUIRED" => true
		],
		'RUANGAN' => [
			"DESCRIPTION" => "Ruangan",
			"REQUIRED" => true
		],
		'STATUS' => 1
	];
}
