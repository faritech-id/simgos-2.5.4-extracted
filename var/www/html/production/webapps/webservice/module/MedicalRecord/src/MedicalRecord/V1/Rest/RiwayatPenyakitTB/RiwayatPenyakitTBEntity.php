<?php
namespace MedicalRecord\V1\Rest\RiwayatPenyakitTB;

use DBService\SystemArrayObject;

class RiwayatPenyakitTBEntity extends SystemArrayObject
{
    protected $fields = [
		"ID"=>1
		, "KUNJUNGAN"=>1
		, "RIWAYAT"=>1
		, "TAHUN"=>1
		, "BEROBAT"=>1
		, "SPUTUM"=>1
		, "TANGGAL_PEMERIKSAAN_SPUTUM"=>1
		, "TEST_CEPAT_MOLEKULER"=>1
		, "TANGGAL_TEST_CEPAT"=>1
		, "TANGGAL"=>1
		, "OLEH"=>1
		, "STATUS"=>1
	];
}
