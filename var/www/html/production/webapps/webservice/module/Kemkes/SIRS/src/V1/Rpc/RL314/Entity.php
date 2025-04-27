<?php
namespace Kemkes\SIRS\V1\Rpc\RL314;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"object_id" => 1
		, "id" => 1
		, "tahun" => 1
		, "no" => 1
		, "jenis_spesialisasi" => 1
		, "rujukan_diterima_dari_puskesmas" => 1
		, "rujukan_diterima_dari_faskes_lainnya" => 1
		, "rujukan_diterima_dari_rs_lain" => 1
		, "rujukan_dikembalikan_ke_puskesmas" => 1
		, "rujukan_dikembalikan_ke_faskes_lainnya" => 1
		, "rujukan_dikembalikan_ke_rs_asal" => 1
		, "dirujuk_pasien_rujukan" => 1
		, "dirujuk_pasien_datang_sendiri" => 1
		, "dirujuk_diterima_kembali" => 1
		, "tanggal_kirim" => 1
		, "kirim" => 1
		, "response" => 1
	];
}
