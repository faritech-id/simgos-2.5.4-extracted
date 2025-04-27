<?php
namespace Kemkes\RSOnline\db\referensi\kecamatan;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"kode" => 1
		, "kabkota" => 1
		, "nama" => 1
	];
}
