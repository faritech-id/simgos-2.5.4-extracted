<?php
namespace Layanan\V1\Rest\PasienMeninggal;
use DBService\SystemArrayObject;

class PasienMeninggalEntity extends SystemArrayObject
{
	protected $fields = [
		'ID' => 1
		, 'KUNJUNGAN' => 1
		, 'NOMOR' => 1
		, 'TANGGAL' => 1
		, 'DIAGNOSA' => 1
		, 'DOKTER' => 1
		, 'RENCANA_PEMULASARAN' => 1
		, 'KEADAAN_YANG_MENGAKIBATKAN_KEMATIAN' => 1
		, 'PENYAKIT_SEBAP_KEMATIAN' => 1
		, 'PENYAKIT_SEBAP_KEMATIAN_LAIN' => 1
		, 'PENYAKIT_LAIN_MEMPENGARUHI_KEMATIAN' => 1
		, 'MULAI_SAKIT' => 1
		, 'AKHIR_SAKIT' => 1
		, 'MACAM_RUDAPAKSA' => 1
		, 'CARA_RUDAPAKSA' => 1
		, 'KERUSAKAN_TUBUH' => 1
		, 'JANIN_LAHIR_MATI' => 1
		, 'SEBAP_KELAHIRAN_MATI' => 1
		, 'PERISTIWA_PERSALINAN' => 1
		, 'PERISTIWA_KEHAMILAN' => 1
		, 'DILAKUKAN_OPERASI' => 1
		, 'BAHASA' => 1
		, 'JENIS_OPERASI' => 1
		, 'CATATAN_VERIFIKASI' => 1
		, 'STATUS_VERIFIKASI' => 1
		, 'VERIFIKATOR' => 1
		, 'OLEH' => 1
		, 'STATUS' => 1
	];
}
