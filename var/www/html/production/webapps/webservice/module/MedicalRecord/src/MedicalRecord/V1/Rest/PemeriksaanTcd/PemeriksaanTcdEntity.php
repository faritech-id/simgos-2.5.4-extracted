<?php
namespace MedicalRecord\V1\Rest\PemeriksaanTcd;
use DBService\SystemArrayObject;

class PemeriksaanTcdEntity extends SystemArrayObject {
    protected $fields = [
		"ID"=>1     
		,"KUNJUNGAN"=>1     
		,"TEMUAN"=>1     
		,"KESAN"=>1     
		,"USUL"=>1     
		,"DIBUAT_TANGGAL"=>1     
		,"OLEH"=>1     
		,"STATUS"=>1  
	];
}
