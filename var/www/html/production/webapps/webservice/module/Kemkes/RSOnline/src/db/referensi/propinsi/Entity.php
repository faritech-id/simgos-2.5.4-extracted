<?php
namespace Kemkes\RSOnline\db\referensi\propinsi;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"prop_kode" => 1
		, "propinsi_name" => 1
	];
}
