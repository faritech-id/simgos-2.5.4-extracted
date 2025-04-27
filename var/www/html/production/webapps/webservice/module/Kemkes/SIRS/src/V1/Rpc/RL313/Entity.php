<?php
namespace Kemkes\SIRS\V1\Rpc\RL313;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"object_id" => 1
		, "id" => 1
		, "tahun" => 1
		, "no" => 1
		, "golongan_obat" => 1
		, "jumlah_item_obat" => 1
		, "jumlah_item_obat_yang_tersedia_di_rs" => 1
		, "jumlah_item_obat_formulatorium_yang_tersedia_di_rs" => 1
		, "tanggal_kirim" => 1
		, "kirim" => 1
		, "response" => 1
	];
}
