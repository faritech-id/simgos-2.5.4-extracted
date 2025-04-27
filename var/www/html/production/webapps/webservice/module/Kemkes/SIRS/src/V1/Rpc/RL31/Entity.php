<?php
namespace Kemkes\SIRS\V1\Rpc\RL31;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"object_id" => 1
		, "id" => 1
		, "tahun" => 1
		, "no" => 1
		, "jenis_pelayanan" => 1
		, "pasien_awal_tahun" => 1
		, "pasien_masuk" => 1
		, "pasien_keluar_hidup" => 1
		, "kurang_48_jam" => 1
		, "lebih_48_jam" => 1
		, "jumlah_lama_dirawat" => 1
		, "pasien_akhir_tahun" => 1
		, "jumlah_hari_perawatan" => 1
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
