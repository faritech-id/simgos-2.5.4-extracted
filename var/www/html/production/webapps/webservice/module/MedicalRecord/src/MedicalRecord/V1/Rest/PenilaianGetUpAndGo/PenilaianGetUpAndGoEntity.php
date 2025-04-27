<?php
namespace MedicalRecord\V1\Rest\PenilaianGetUpAndGo;

use DBService\SystemArrayObject;

class PenilaianGetUpAndGoEntity extends SystemArrayObject {
    protected $fields = [
		"ID"=>1     
		, "KUNJUNGAN"=>1     
		, "CARA_BERJALAN_PASIEN"=>1     
		, "FAKTOR_RESIKO"=>1     
		, "OBAT_YANG_DIMINUM"=>1
		, "TANGGAL"=>1     
		, "OLEH"=>1     
		, "STATUS"=>1   
    ];
}
