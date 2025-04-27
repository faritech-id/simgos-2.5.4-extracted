<?php
namespace Layanan\V1\Rest\BatasLayananObat;
use DBService\SystemArrayObject;

class BatasLayananObatEntity extends SystemArrayObject
{
	protected $fields = [
		'ID'=>1, 
		'NORM'=>1, 
		'FARMASI'=>1, 
		'TANGGAL'=>1, 
		'OLEH'=>1, 
		'REF'=>1
	];
}
