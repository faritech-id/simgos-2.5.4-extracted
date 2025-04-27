<?php
namespace Kemkes\SIRS\V1\Rpc\RL315;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"object_id" => 1
		, "id" => 1
		, "tahun" => 1
		, "no" => 1
		, "cara_pembayaran" => 1
		, "pasien_rawat_inap_jpk" => 1
		, "pasien_rawat_inap_jld" => 1
		, "jumlah_pasien_rawat_jalan" => 1
		, "jumlah_pasien_rawat_jalan_lab" => 1
		, "jumlah_pasien_rawat_jalan_rad" => 1
		, "jumlah_pasien_rawat_jalan_ll" => 1
		, "tanggal_kirim" => 1
		, "kirim" => 1
		, "response" => 1
	];
}
