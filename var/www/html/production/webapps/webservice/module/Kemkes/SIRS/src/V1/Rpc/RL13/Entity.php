<?php
namespace Kemkes\SIRS\V1\Rpc\RL13;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"object_id" => 1
		, "id" => 1
		, "tahun" => 1
		, "no" => 1
		, "jenis_pelayanan" => 1
		, "jumlah_tt" => 1
		, "vvip" => 1
		, "vip" => 1
		, "i" => 1
		, "ii" => 1
		, "iii" => 1
		, "kelas_khusus" => 1
		, "tanggal_kirim" => 1
		, "kirim" => 1
		, "response" => 1
	];
}
