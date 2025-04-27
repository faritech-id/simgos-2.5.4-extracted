<?php
namespace MedicalRecord\V1\Rest\RiwayatPenyakitKeluarga;

use DBService\SystemArrayObject;

class RiwayatPenyakitKeluargaEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1
		, "KUNJUNGAN"=>1
		, "HIPERTENSI"=>1
		, "DIABETES_MELITUS"=>1
		, "PENYAKIT_JANTUNG"=>1
		, "ASMA"=>1
		, "LAINNYA"=>1
		, "TANGGAL"=>1
		, "OLEH"=>1
		, "STATUS"=>1
	];
}