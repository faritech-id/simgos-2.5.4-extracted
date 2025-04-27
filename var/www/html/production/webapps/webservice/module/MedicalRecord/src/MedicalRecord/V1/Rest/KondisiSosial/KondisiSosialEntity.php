<?php
namespace MedicalRecord\V1\Rest\KondisiSosial;

use DBService\SystemArrayObject;

class KondisiSosialEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1
		, "KUNJUNGAN"=>1
		, "MARAH"=>1
		, "CEMAS"=>1
		, "TAKUT"=>1
		, "BUNUH_DIRI"=>1
		, "SEDIH"=>1
		, "LAINNYA"=>1
		, "STATUS_MENTAL"=>1
		, "MASALAH_PERILAKU"=>1
		, "PERILAKU_KEKERASAN_DIALAMI_SEBELUMNYA"=>1
		, "HUBUNGAN_PASIEN_DENGAN_KELUARGA"=>1
		, "TEMPAT_TINGGAL"=>1
		, "TEMPAT_TINGGAL_LAINNYA"=>1
		, "KEBIASAAN_BERIBADAH_TERATUR"=>1
		, "NILAI_KEPERCAYAAN"=>1
		, "NILAI_KEPERCAYAAN_DESKRIPSI"=>1
		, "PENGAMBIL_KEPUTUSAN_DALAM_KELUARGA"=>1
		, "PENGHASILAN_PERBULAN"=>1
		, "TANGGAL"=>1
		, "OLEH"=>1
		, "STATUS"=>1
	];
}