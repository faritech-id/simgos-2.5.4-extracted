<?php
namespace MedicalRecord\V1\Rest\PemeriksaanEkg;
use DBService\SystemArrayObject;

class PemeriksaanEkgEntity extends SystemArrayObject
{
    protected $fields = [
		"ID"=>1     
		,"KUNJUNGAN"=>1     
		,"IRAMA"=>1     
		,"GEL_P"=>1
		,"GEL_P_LAINNYA"=>1   
		,"QRS_KOMPLEKS"=>1
		,"QRS_KOMPLEKS_LAINNYA"=>1     
		,"REGULARITAS"=>1     
		,"PR_INTERVAL"=>1     
		,"PR_INTERVAL_LAINNYA"=>1     
		,"ST_SEGMEN"=>1     
		,"HEART_RATE"=>1     
		,"AXIX"=>1     
		,"GEL_T"=>1     
		,"KESIMPULAN"=>1     
		,"DOKUMENT"=>1     
		,"DIBUAT_TANGGAL"=>1
		,"OLEH"=>1     
		,"STATUS"=>1  
	];
}
