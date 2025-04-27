<?php
namespace Layanan\V1\Rest\PemakaianBhpDetil;
use DBService\SystemArrayObject;

class PemakaianBhpDetilEntity extends SystemArrayObject
{
	protected $fields = [
		'ID'=>1
		, 'PEMAKAIAN'=>1
		, 'BARANG'=>1
		, 'JUMLAH'=>1
		, 'STATUS'=>1
	];
}