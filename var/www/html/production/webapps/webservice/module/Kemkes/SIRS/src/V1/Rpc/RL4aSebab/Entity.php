<?php
namespace Kemkes\SIRS\V1\Rpc\RL4aSebab;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"object_id" => 1
		, "id" => 1
		, "tahun" => 1
		, "no_dtd" => 1
		, "no_urut" => 1
		, "no_daftar_terperinci" => 1
		, "golongan_sebab_penyakit" => 1
		, "jumlah_pasien_hidup_mati_0-<=6_hari_l" => 1
		, "jumlah_pasien_hidup_mati_0-<=6_hari_p" => 1
		, "jumlah_pasien_hidup_mati_>6-<=28_hari_l" => 1
		, "jumlah_pasien_hidup_mati_>6-<=28_hari_p" => 1
		, "jumlah_pasien_hidup_mati_>28_hari-<=1_tahun_l" => 1
		, "jumlah_pasien_hidup_mati_>28_hari-<=1_tahun_p" => 1
		, "jumlah_pasien_hidup_mati_>1-<=4_tahun_l" => 1
		, "jumlah_pasien_hidup_mati_>1-<=4_tahun_p" => 1
		, "jumlah_pasien_hidup_mati_>4-<=14_tahun_l" => 1
		, "jumlah_pasien_hidup_mati_>4-<=14_tahun_p" => 1
		, "jumlah_pasien_hidup_mati_>14-<=24_tahun_l" => 1
		, "jumlah_pasien_hidup_mati_>14-<=24_tahun_p" => 1
		, "jumlah_pasien_hidup_mati_>24-<=44_tahun_l" => 1
		, "jumlah_pasien_hidup_mati_>24-<=44_tahun_p" => 1
		, "jumlah_pasien_hidup_mati_>44-<=64_tahun_l" => 1
		, "jumlah_pasien_hidup_mati_>44-<=64_tahun_p" => 1
		, "jumlah_pasien_hidup_mati_>64_tahun_l" => 1
		, "jumlah_pasien_hidup_mati_>64_tahun_p" => 1
		, "pasien_keluar_hidup_mati_l" => 1
		, "pasien_keluar_hidup_mati_p" => 1
		, "jumlah_pasien_keluar_hidup_mati" => 1
		, "jumlah_pasien_keluar_mati" => 1
		, "tanggal_kirim" => 1
		, "kirim" => 1
		, "response" => 1
	];
}
