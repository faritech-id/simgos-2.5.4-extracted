<?php
namespace Kemkes\SIRS\V1\Rpc\RL4b;

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
		, "0-<=6_hari_l" => 1
		, "0-<=6_hari_p" => 1
		, ">6-<=28_hari_l" => 1
		, ">6-<=28_hari_p" => 1
		, ">28_hari-<=1_tahun_l" => 1
		, ">28_hari-<=1_tahun_p" => 1
		, ">1-<=4_tahun_l" => 1
		, ">1-<=4_tahun_p" => 1
		, ">4-<=14_tahun_l" => 1
		, ">4-<=14_tahun_p" => 1
		, ">14-<=24_tahun_l" => 1
		, ">14-<=24_tahun_p" => 1
		, ">24-<=44_tahun_l" => 1
		, ">24-<=44_tahun_p" => 1
		, ">44-<=64_tahun_l" => 1
		, ">44-<=64_tahun_p" => 1
		, ">64_tahun_l" => 1
		, ">64_tahun_p" => 1
		, "kasus_baru_menurut_jenis_kelamain_l" => 1
		, "kasus_baru_menurut_jenis_kelamain_p" => 1
		, "jumlah_kasus_baru" => 1
		, "jumlah_kunjungan" => 1
		, "tanggal_kirim" => 1
		, "kirim" => 1
		, "response" => 1
	];
}
