<?php
namespace Kemkes\SIRS\V1\Rpc\RL32;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"object_id" => 1
		, "id" => 1
		, "tahun" => 1
		, "no" => 1
		, "jenis_pelayanan" => 1
		, "total_pasien_rujukan" => 1
		, "total_pasien_non_rujukan" => 1
		, "tindak_lanjut_pelayanan_dirawat" => 1
		, "tindak_lanjut_pelayanan_dirujuk" => 1
		, "tindak_lanjut_pelayanan_pulang" => 1
		, "mati_di_ugd" => 1
		, "doa" => 1
		, "tanggal_kirim" => 1
		, "kirim" => 1
		, "response" => 1
	];
}
