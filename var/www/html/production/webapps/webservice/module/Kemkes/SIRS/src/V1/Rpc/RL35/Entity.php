<?php
namespace Kemkes\SIRS\V1\Rpc\RL35;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"object_id" => 1
		, "id" => 1
		, "tahun" => 1
		, "no" => 1
		, "jenis_kegiatan" => 1
		, "rm_rumah_sakit" => 1
		, "rm_bidan" => 1
		, "rm_puskesmas" => 1
		, "rm_faskes_lainnya" => 1
		, "rm_mati" => 1
		, "rm_total" => 1
		, "rnm_mati" => 1
		, "rnm_total" => 1	
		, "nr_mati" => 1
		, "nr_total" => 1
		, "dirujuk" => 1
		, "tanggal_kirim" => 1
		, "kirim" => 1
		, "response" => 1
	];
}
