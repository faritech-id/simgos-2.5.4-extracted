<?php
namespace Kemkes\SIRS\V1\Rpc\RL33;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"object_id" => 1
		, "id" => 1
		, "tahun" => 1
		, "no" => 1
		, "jenis_kegiatan" => 1
		, "jumlah" => 1
		, "tanggal_kirim" => 1
		, "kirim" => 1
		, "response" => 1
	];
}
