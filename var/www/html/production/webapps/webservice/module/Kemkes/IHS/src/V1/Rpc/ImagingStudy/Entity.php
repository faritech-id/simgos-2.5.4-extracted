<?php
namespace Kemkes\IHS\V1\Rpc\ImagingStudy;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"id" => 1,
		"nopen" => 1,
		"refId" => [
			"REQUIRED" => true
		],
		"get" => 1
	];
}