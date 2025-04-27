<?php
namespace General\V1\Rest\DepoLayananFarmasi;
use DBService\SystemArrayObject;

class DepoLayananFarmasiEntity extends SystemArrayObject
{
	protected $fields = [
		'ID' => 1,
        'RUANGAN_FARMASI' => 1,
        'RUANGAN_LAYANAN' => 1,
		'MULAI' => 1,
		'SELESAI' => 1,
        'OLEH' => 1,
		'STATUS' => 1,
		'INDEKS' => 1
	];
}