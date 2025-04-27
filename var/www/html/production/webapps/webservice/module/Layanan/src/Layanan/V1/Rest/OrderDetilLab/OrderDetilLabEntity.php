<?php
namespace Layanan\V1\Rest\OrderDetilLab;
use DBService\SystemArrayObject;

class OrderDetilLabEntity extends SystemArrayObject
{
	protected $fields = [
		'ORDER_ID' => 1, 
		'TINDAKAN' => 1, 
		'REF' => 1
	];
}
