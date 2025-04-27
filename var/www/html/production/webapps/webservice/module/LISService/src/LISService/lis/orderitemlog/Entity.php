<?php
namespace LISService\lis\orderitemlog;
use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		'HIS_ID'=>1, 
		'TANGGAL'=>1, 
		'STATUS'=>1
	];
}

