<?php
namespace Layanan\V1\Rest\PermintaanDarahDetail;
use DBService\SystemArrayObject;

class PermintaanDarahDetailEntity extends SystemArrayObject
{
	protected $fields = [
		'NOMOR'=>1
		, 'KUNJUNGAN'=>1
		, 'KOMPONEN'=>1
		, 'QTY'=>1
		, 'ORDER_ID'=>1
		, 'DIBUAT_TANGGAL'=>1
		, 'OLEH'=>1
		, 'STATUS'=>1
	];
}
