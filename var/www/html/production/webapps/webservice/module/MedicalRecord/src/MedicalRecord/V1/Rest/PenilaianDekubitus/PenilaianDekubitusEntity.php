<?php
namespace MedicalRecord\V1\Rest\PenilaianDekubitus;
use DBService\SystemArrayObject;

class PenilaianDekubitusEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1
		, "KUNJUNGAN"=>1
		, "KONDISI_FISIK"=>1
		, "KESADARAN"=>1
        , "AKTIVITAS"=>1
		, "MOBILITAS"=>1
        , "INKONTINENSIA"=>1
		, "TANGGAL"=>1
		, "OLEH"=>1
		, "STATUS"=>1
    ];
}