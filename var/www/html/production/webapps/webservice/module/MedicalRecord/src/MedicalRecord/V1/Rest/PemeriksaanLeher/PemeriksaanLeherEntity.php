<?php
namespace MedicalRecord\V1\Rest\PemeriksaanLeher;

use DBService\SystemArrayObject;

class PemeriksaanLeherEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1     
		,"KUNJUNGAN"=>1     
		,"PENDAFTARAN"=>1     
		,"JVP"=>1     
		,"PKL"=>1     
		,"PKL_DESKRIPSI"=>1     
		,"KAKUDUK"=>1     
		,"KAKUDUK_DESKRIPSI"=>1     
		,"ADA_KELAINAN"=>1     
		,"DESKRIPSI"=>1     
		,"TANGGAL"=>1     
		,"OLEH"=>1
		,"STATUS"=>1  
	];
}