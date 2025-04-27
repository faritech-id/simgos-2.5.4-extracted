<?php
namespace Kemkes\RSOnline\db\referensi\kabupaten;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"kode" => 1
		, "propinsi" => 1
		, "nama" => 1
	];
}
