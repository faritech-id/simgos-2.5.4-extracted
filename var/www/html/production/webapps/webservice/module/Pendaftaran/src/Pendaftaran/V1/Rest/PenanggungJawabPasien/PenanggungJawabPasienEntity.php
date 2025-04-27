<?php
namespace Pendaftaran\V1\Rest\PenanggungJawabPasien;
use DBService\SystemArrayObject;

class PenanggungJawabPasienEntity extends SystemArrayObject
{
	protected $fields = [
		'ID'=>1, 
		'NOPEN'=>1, 
		'REF'=>1, 
		'SHDK'=>1, 
		'JENIS_KELAMIN'=>1, 
		'NAMA'=>1, 
		'ALAMAT'=>1, 
		'PENDIDIKAN'=>1, 
		'PEKERJAAN'=>1
	];
}
