<?php
namespace MedicalRecord\V1\Rest\PenilaianSkalaMorse;

use DBService\SystemArrayObject;

class PenilaianSkalaMorseEntity extends SystemArrayObject {
    protected $fields = [
		"ID"=>1     
		, "KUNJUNGAN"=>1     
		, "RIWAYAT_JATUH"=>1     
		, "DIAGNOSIS"=>1     
		, "ALAT_BANTU"=>1     
		, "HEPARIN"=>1     
		, "GAYA_BERJALAN"=>1     
		, "KESADARAN"=>1     
		, "TANGGAL"=>1     
		, "OLEH"=>1     
		, "STATUS"=>1   
    ];
}
