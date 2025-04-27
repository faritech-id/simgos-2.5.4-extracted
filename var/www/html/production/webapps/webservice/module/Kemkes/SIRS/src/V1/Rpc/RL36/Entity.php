<?php
namespace Kemkes\SIRS\V1\Rpc\RL36;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"object_id" => 1
		, "id" => 1
		, "tahun" => 1
		, "no" => 1
		, "spesialisasi" => 1
		, "total" => 1
		, "khusus" => 1
		, "besar" => 1
		, "sedang" => 1
		, "kecil" => 1
		, "tanggal_kirim" => 1
		, "kirim" => 1
		, "response" => 1
	];
}
