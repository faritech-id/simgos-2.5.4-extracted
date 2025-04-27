<?php
namespace MedicalRecord\V1\Rest\PemeriksaanCatClams;
use DBService\SystemArrayObject;

class PemeriksaanCatClamsEntity extends SystemArrayObject
{
    protected $fields = [
		"ID"=>1     
		,"KUNJUNGAN"=>1     
		,"KELUHAN_UTAMA"=>1     
		,"OBJEKTIF"=>1     
		,"ASESMENT_CAT_CLAMS"=>1     
		,"ANJURAN"=>1     
		,"DIBUAT_TANGGAL"=>1     
		,"OLEH"=>1     
		,"STATUS"=>1  
	];
}
