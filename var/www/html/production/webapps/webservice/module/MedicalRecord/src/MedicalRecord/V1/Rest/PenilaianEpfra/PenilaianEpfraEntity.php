<?php
namespace MedicalRecord\V1\Rest\PenilaianEpfra;
use DBService\SystemArrayObject;

class PenilaianEpfraEntity extends SystemArrayObject
{
	protected $fields = [
		  "ID"=>1
		, "KUNJUNGAN"=>1
		, "USIA"=>1
		, "STATUS_MENTAL"=>1
        , "ELIMINASI"=>1
		, "MEDIKASI"=>1
        , "DIAGNOSIS"=>1
        , "AMBULASI"=>1
		, "NUTRISI"=>1
        , "GANGGUAN_TIDUR"=>1
        , "RIWAYAT_JATUH"=>1
        , "TANGGAL"=>1
		, "OLEH"=>1
		, "STATUS"=>1
    ];
}