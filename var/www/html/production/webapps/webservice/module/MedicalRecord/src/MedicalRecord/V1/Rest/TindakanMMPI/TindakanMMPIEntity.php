<?php
namespace MedicalRecord\V1\Rest\TindakanMMPI;
use DBService\SystemArrayObject;

class TindakanMMPIEntity extends SystemArrayObject
{
    protected $fields = [
		"ID"=>1     
		,"KUNJUNGAN"=>1     
		,"KEBUTUHAN"=>1     
		,"HASIL"=>1     
		,"DOKTER"=>1     
		,"DIBUAT_TANGGAL"=>1
		,"OLEH"=>1     
		,"STATUS"=>1  
	];
}
