<?php
namespace MedicalRecord\V1\Rest\StatusFungsional;

use DBService\SystemArrayObject;

class StatusFungsionalEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1
		, "KUNJUNGAN"=>1
		, "TANPA_ALAT_BANTU"=>1
		, "TONGKAT"=>1
		, "KURSI_RODA"=>1
		, "BRANKARD"=>1
		, "WALKER"=>1
		, "ALAT_BANTU"=>1
		, "CACAT_TUBUH_TIDAK"=>1
		, "CACAT_TUBUH_YA"=>1
		, "KET_CACAT_TUBUH"=>1
		, "TANGGAL"=>1
		, "OLEH"=>1
		, "STATUS"=>1
    ];
}