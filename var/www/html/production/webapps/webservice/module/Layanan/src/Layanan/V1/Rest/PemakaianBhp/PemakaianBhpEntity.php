<?php
namespace Layanan\V1\Rest\PemakaianBhp;
use DBService\SystemArrayObject;

class PemakaianBhpEntity extends SystemArrayObject
{
	protected $fields = [
		'ID'=>1
		, 'KUNJUNGAN'=>1
		, 'RUANGAN'=>1
		, 'TANGGAL'=>1
		, 'KETERANGAN'=>1
		, 'OLEH'=>1
		, 'STATUS'=>1
	];
}
