<?php
namespace MedicalRecord\V1\Rest\PemeriksaanDada;

use DBService\SystemArrayObject;

class PemeriksaanDadaEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1     
		,"KUNJUNGAN"=>1     
		,"PENDAFTARAN"=>1     
		,"THORAKS_SIMETRIS"=>1     
		,"THORAKS_ASIMETRIS"=>1     
		,"THORAKS_DESKRIPSI"=>1     
		,"COR"=>1     
		,"REGULER"=>1     
		,"IREGULER"=>1     
		,"MURMUR"=>1     
		,"LAIN_LAIN"=>1     
		,"PULMO_SUARA_NAFAS"=>1     
		,"RONCHI"=>1     
		,"RONCHI_DEKSRIPSI"=>1     
		,"WHEEZING"=>1     
		,"WHEEZING_DESKRIPSI"=>1     
		,"ADA_KELAINAN"=>1     
		,"DESKRIPSI"=>1     
		,"TANGGAL"=>1     
		,"OLEH"=>1
		,"STATUS"=>1  
	];
}
