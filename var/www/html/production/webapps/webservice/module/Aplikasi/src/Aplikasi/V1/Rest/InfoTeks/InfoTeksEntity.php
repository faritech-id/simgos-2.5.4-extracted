<?php
namespace Aplikasi\V1\Rest\InfoTeks;
use DBService\SystemArrayObject;

class InfoTeksEntity extends SystemArrayObject
{
	protected $fields = [
		'ID'=>1
		, 'JENIS'=>1
		, 'TEKS'=>1
		, 'WARNA'=>1
		, 'PUBLISH'=>1
		, 'TANGGAL'=>1
		, 'OLEH'=>1
		, 'STATUS'=>1
	];
}
