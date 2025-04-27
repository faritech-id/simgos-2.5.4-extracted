<?php
namespace Kemkes\SIRS\V1\Rpc\RL12;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"object_id" => 1
		, "id" => 1
		, "tahun" => 1
		, "bor" => 1
		, "los" => 1
		, "bto" => 1
		, "toi" => 1
		, "ndr" => 1
		, "gdr" => 1
		, "ratakunjungan" => 1
		, "tanggal_kirim" => 1
		, "kirim" => 1
		, "response" => 1
	];
}
