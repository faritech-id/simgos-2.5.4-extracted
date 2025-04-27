<?php
namespace Kemkes\db\siranap\tempat_tidur;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = array(
		"kode_ruang" => 1
		, "tipe_pasien" => 1
		, "total_TT" => 1
		, "terpakai_male" => 1
		, "terpakai_female" => 1
		, "kosong_male" => 1
		, "kosong_female" => 1
		, "waiting" => 1
		, "tgl_update" => 1
	);
}
