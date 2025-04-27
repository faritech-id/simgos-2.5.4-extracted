<?php
namespace MedicalRecord\V1\Rest\FaktorRisiko;

use DBService\SystemArrayObject;

class FaktorRisikoEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1
		, "KUNJUNGAN"=>1
		, "HIPERTENSI"=>1
		, "DIABETES_MELITUS"=>1
		, "PENYAKIT_JANTUNG"=>1
		, "ASMA"=>1
		, "STROKE"=>1
		, "LIVER"=>1
		, "GINJAL"=>1
		, "TUBERCULOSIS_PARU"=>1
		, "ROKOK"=>1
		, "MINUM_ALKOHOL"=>1
		, "PERILAKU_LAIN"=>1
		, "PENYAKIT_LAIN"=>1
		, "MINUMAN_ALKOHOL"=>1
		, "MEROKOK"=>1
		, "BEGADANG"=>1
		, "SEKS_BEBAS"=>1
		, "NAPZA_TAMPA_RESEP_DOKTER"=>1
		, "MAKAN_MANIS_BERLEBIHAN"=>1
		, "PERILAKU_LGBT"=>1
		, "PERNAH_DIRAWAT_TIDAK"=>1
		, "PERNAH_DIRAWAT_YA"=>1
		, "PERNAH_DIRAWAT_KAPAN"=>1
		, "PERNAH_DIRAWAT_DIMANA"=>1
		, "PERNAH_DIRAWAT_DIAGNOSIS"=>1
		, "TANGGAL"=>1
		, "OLEH"=>1
		, "STATUS"=>1
	];
}
