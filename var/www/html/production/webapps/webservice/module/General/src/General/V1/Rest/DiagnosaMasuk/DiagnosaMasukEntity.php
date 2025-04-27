<?php
namespace General\V1\Rest\DiagnosaMasuk;
use DBService\SystemArrayObject;

class DiagnosaMasukEntity extends SystemArrayObject
{
	protected $fields = [
		'ID'=>1, 
		'ICD'=>1, 
		'DIAGNOSA'=>1
	];
}
