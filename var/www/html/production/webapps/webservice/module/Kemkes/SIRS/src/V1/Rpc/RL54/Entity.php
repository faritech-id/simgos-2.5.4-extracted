<?php
namespace Kemkes\SIRS\V1\Rpc\RL54;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"object_id" => 1
		, "id" => 1
		, "tahun" => 1
		, "bulan" => 1
		, "kode_icd_10" => 1
		, "no_urut" => 1
		, "deskripsi" => 1
		, "kasus_baru_menurut_jenis_kelamin_l" => 1
		, "kasus_baru_menurut_jenis_kelamin_p" => 1
		, "jumlah_kasus_baru" => 1
		, "jumlah_kunjungan" => 1
		, "tanggal_kirim" => 1
		, "kirim" => 1
		, "response" => 1
	];
}
