<?php
namespace Layanan\V1\Rest\BonSisa;
use DBService\SystemArrayObject;

class BonSisaEntity extends SystemArrayObject
{
	protected $fields = [
		'ID' => 1,
        'REF' => 1,
        'FARMASI' => 1,
		'JUMLAH' => 1,
		'SISA' => 1,
        'TANGGAL' => 1,
        'OLEH' => 1,
		'STATUS' => 1
	];
}