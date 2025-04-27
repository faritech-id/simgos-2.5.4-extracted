<?php
namespace Kemkes\SIRS\V1\Rpc\RL313b;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"object_id" => 1
		, "id" => 1
		, "tahun" => 1
		, "no" => 1
		, "golongan_obat" => 1
		, "rawat_jalan" => 1
		, "igd" => 1
		, "rawat_inap" => 1
		, "tanggal_kirim" => 1
		, "kirim" => 1
		, "response" => 1
	];
}
