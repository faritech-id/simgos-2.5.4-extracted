<?php
namespace Kemkes\SIRS\V1\Rpc\RL312;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"object_id" => 1
		, "id" => 1
		, "tahun" => 1
		, "no" => 1
		, "metoda" => 1
		, "konseling_anc" => 1
		, "kenseling_pasca_persalinan" => 1
		, "kb_baru_dengan_cara_masuk_bukan_rujukan" => 1
		, "kb_baru_dengan_cara_masuk_rujukan_r_inap" => 1
		, "kb_baru_dengan_cara_masuk_rujukan_r_jalan" => 1
		, "kb_baru_dengan_cara_masuk_total" => 1
		, "kb_baru_dengan_kondisi_pasca_persalinan_atau_nifas" => 1
		, "kb_baru_dengan_kondisi_abortus" => 1
		, "kb_baru_dengan_kondisi_lainnya" => 1
		, "kunjungan_ulang" => 1
		, "keluhan_efek_samping_jumlah" => 1
		, "keluhan_efek_samping_dirujuk" => 1
		, "tanggal_kirim" => 1	
		, "kirim" => 1
		, "response" => 1	
	];
}
