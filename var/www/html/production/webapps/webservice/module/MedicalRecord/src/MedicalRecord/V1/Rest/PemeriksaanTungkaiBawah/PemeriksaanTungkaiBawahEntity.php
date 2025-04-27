<?php
namespace MedicalRecord\V1\Rest\PemeriksaanTungkaiBawah;

use DBService\SystemArrayObject;

class PemeriksaanTungkaiBawahEntity extends SystemArrayObject {
    protected $fields = [
		"ID"=>1     
		,"KUNJUNGAN"=>1     
		,"PENDAFTARAN"=>1     
		,"ADA_KELAINAN"=>1     
		,"DESKRIPSI"=>1     
		,"TANGGAL"=>1     
		,"OLEH"=>1     
		,"STATUS"=>1  
	];
}
