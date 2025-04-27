<?php
namespace BPJService\db\referensi;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"id" => 1
		, "jenis_referensi_id" => 1
		, "kode" => 1
		, "deskripsi" => 1
		, "status" => 1
	];
}
