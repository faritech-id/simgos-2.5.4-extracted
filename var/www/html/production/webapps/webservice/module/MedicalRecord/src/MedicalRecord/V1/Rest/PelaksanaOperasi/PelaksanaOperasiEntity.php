<?php
namespace MedicalRecord\V1\Rest\PelaksanaOperasi;

use DBService\SystemArrayObject;

class PelaksanaOperasiEntity extends SystemArrayObject
{
    protected $fields = [
		"ID"=>1     
		,"OPERASI_ID"=>1     
		,"JENIS"=>1     
		,"PELAKSANA"=>1
		,"STATUS"=>1  
	];
}
