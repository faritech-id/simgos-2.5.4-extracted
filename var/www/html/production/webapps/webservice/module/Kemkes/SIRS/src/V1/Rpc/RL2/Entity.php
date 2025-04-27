<?php
namespace Kemkes\SIRS\V1\Rpc\RL2;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"object_id" => 1
		, "id" => 1
		, "tahun" => 1
		, "no_kode" => 1
		, "kualifikasi_pendidikan" => 1
		, "keadaan_laki_laki" => 1
		, "keadaan_perempuan" => 1
		, "kebutuhan_laki_laki" => 1
		, "kebutuhan_perempuan" => 1
		, "kekurangan_laki_laki" => 1
		, "kekurangan_perempuan" => 1
		, "tanggal_kirim" => 1
		, "kirim" => 1
		, "response" => 1
	];
}
