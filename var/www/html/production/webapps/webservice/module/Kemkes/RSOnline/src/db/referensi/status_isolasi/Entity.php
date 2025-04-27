<?php
namespace Kemkes\RSOnline\db\referensi\status_isolasi;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"id_isolasi" => 1
		, "id_status_rawat" => 1
		, "status_isolasi" => 1
	];
}
