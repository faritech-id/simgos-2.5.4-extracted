<?php
namespace Pendaftaran\V1\Rest\AntrianRuangan;
use DBService\SystemArrayObject;

class AntrianRuanganEntity extends SystemArrayObject
{
	protected $fields = [
		'ID'=>1, 
		'RUANGAN'=>1, 
		'TANGGAL'=>1, 
		'POS'=>1,
		'NOMOR'=>1,
		'JENIS'=>1,
		'REF'=>1, 
		'STATUS'=>1
	];
}