<?php
namespace MedicalRecord\V1\Rest\PermasalahGiziPasien;
use DBService\SystemArrayObject;

class PermasalahGiziPasienEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1
		, "KUNJUNGAN"=>1
		, "BERAT_BADAN_SIGNIFIKAN"=>1
		, "PERUBAHAN_BERAT_BADAN"=>1
		, "INTAKE_MAKANAN"=>1
		, "KONDISI_KHUSUS"=>1
		, "SKOR"=>1
		, "STATUS_SKOR"=>1
		, "TANGGAL"=>1
		, "OLEH"=>1
		, "STATUS_VALIDASI"=>1
		, "TANGGAL_VALIDASI"=>1
		, "USER_VALIDASI"=>1
		, "STATUS"=>1
    ];
}
