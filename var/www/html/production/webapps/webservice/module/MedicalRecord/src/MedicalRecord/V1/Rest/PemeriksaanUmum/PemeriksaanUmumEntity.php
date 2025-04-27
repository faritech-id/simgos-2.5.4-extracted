<?php
namespace MedicalRecord\V1\Rest\PemeriksaanUmum;
use DBService\SystemArrayObject;

class PemeriksaanUmumEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1,
		"KUNJUNGAN"=>1,
		"BERAT_BADAN"=>1,
		"TINGGI_BADAN"=>1,
		"INDEX_MASSA_TUBUH"=>1,
		"LINGKAR_KEPALA"=>1,
		"ALAT_BANTU"=>1,
		"PROTHESA"=>1,
		"CACAT_TUBUH"=>1,
		"TANGGAL"=>1,
		"OLEH"=>1,
		"STATUS"=>1
    ];
}
