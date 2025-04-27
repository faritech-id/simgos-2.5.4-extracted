<?php
namespace Kemkes\IHS\V1\Rpc\Practitioner;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"id" => 1,
		"refId" => 1,
		'address' => 1,
		"birthDate" => 1,
		"gender" => 1,
		"identifier" => 1,
		"meta" => 1,
		"name" => 1,
		"qualification" => 1,
		"telecom" => 1,
		"get" => 1
	];
}