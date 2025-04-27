<?php
namespace General\V1\Rest\Perawat;
use DBService\SystemArrayObject;

class PerawatEntity extends SystemArrayObject
{
	protected $fields = [
		'ID' => 1, 
		'NIP' => 1, 
		'STATUS' => 1
	];
}
