<?php
namespace MedicalRecord\V1\Rest\PemeriksaanMata;

use DBService\SystemArrayObject;

class PemeriksaanMataEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1     
		,"KUNJUNGAN"=>1     
		,"PENDAFTARAN"=>1     
		,"ANEMIS"=>1         
		,"IKTERUS"=>1     
		,"PUPIL_ISOKOR"=>1     
		,"PUPIL_ANISOKOR"=>1     
		,"DIAMETER_ISIAN"=>1     
		,"DIAMETER_MM"=>1     
		,"UDEM"=>1        
		,"ADA_KELAINAN"=>1     
		,"DESKRIPSI"=>1     
		,"TANGGAL"=>1     
		,"OLEH"=>1
		,"STATUS"=>1  
	];
}
