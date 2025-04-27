<?php
namespace Pendaftaran\V1\Rest\KontakPengantarPasien;
use DBService\SystemArrayObject;

class KontakPengantarPasienEntity extends SystemArrayObject
{
	protected $fields = [
		'JENIS'=>1, 
		'ID'=>1, 
		'NOMOR'=>1
	];
}
