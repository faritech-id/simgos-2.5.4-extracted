<?php
namespace MedicalRecord\V1\Rest\EdukasiEndOfLife;

use DBService\SystemArrayObject;

class EdukasiEndOfLifeEntity extends SystemArrayObject
{
    protected $fields = [
		"ID"=>1
		, "KUNJUNGAN"=>1
		, "MENGETAHUI_DIAGNOSA"=>1
		, "MENGETAHUI_PROGNOSIS"=>1
		, "MENGETAHUI_TUJUAN_PERAWATAN"=>1
		, "TANGGAL"=>1
		, "OLEH"=>1
		, "STATUS"=>1
    ];
}
