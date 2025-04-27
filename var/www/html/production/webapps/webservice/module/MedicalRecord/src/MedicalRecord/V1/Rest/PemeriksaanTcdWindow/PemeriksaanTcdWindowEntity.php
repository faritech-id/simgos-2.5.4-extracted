<?php
namespace MedicalRecord\V1\Rest\PemeriksaanTcdWindow;
use DBService\SystemArrayObject;

class PemeriksaanTcdWindowEntity  Extends SystemArrayObject {
    protected $fields = [
		"ID"=>1     
		,"KUNJUNGAN"=>1     
		,"REFERENSI_JENIS"=>1     
		,"REFERENSI_ID"=>1     
		,"MAX"=>1     
		,"MEAN"=>1     
		,"PI"=>1     
		,"RI"=>1     
		,"DIBUAT_TANGGAL"=>1     
		,"OLEH"=>1     
		,"STATUS"=>1  
	];
}
