<?php
namespace Kemkes\RSOnline\db\referensi\jenis_pasien;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"id_jenis_pasien" => 1
		, "deskripsi" => 1
	];
}
