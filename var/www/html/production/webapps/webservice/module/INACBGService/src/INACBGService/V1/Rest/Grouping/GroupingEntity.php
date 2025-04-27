<?php
namespace INACBGService\V1\Rest\Grouping;
use DBService\SystemArrayObject;

class GroupingEntity extends SystemArrayObject
{
	protected $fields = [
		'NOPEN'=>1, 
		'DATA'=>1
	];
}
