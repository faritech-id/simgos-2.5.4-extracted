<?php
namespace General\V1\Rest\Ruangan;
use DBService\SystemArrayObject;

class RuanganEntity extends SystemArrayObject
{
	protected $fields = [
		'ID'=>1, 
		'JENIS'=>1, 
		'JENIS_KUNJUNGAN'=>1, 
		'REF_ID'=>1, 
		'DESKRIPSI'=>1, 
		'AKSES_PERMINTAAN'=>1,
		'STATUS'=>1
	];
}
