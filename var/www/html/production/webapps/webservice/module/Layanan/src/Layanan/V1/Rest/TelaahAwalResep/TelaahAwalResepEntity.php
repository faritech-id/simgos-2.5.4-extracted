<?php
namespace Layanan\V1\Rest\TelaahAwalResep;
use DBService\SystemArrayObject;

class TelaahAwalResepEntity extends SystemArrayObject
{
	protected $fields = [
		'ID' => 1,
        'JENIS' => 1,
        'RESEP' => 1,
        'REF_TELAAH' => 1,
        'OLEH' => 1,
		'STATUS' => 1
	];
}