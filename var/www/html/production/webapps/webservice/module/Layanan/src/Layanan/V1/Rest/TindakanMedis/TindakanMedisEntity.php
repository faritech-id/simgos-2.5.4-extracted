<?php
namespace Layanan\V1\Rest\TindakanMedis;
use DBService\SystemArrayObject;

class TindakanMedisEntity extends SystemArrayObject
{
	protected $fields = [
		'ID'=>1, 
		'KUNJUNGAN'=>1, 
		'TINDAKAN'=>1, 
		'TANGGAL'=>1, 
		'OLEH'=>1, 
		'OTOMATIS'=>1,
		'STATUS'=>1
	];
}
