<?php
namespace Kemkes\IHS\V1\Rpc\Organization;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"id" => 1,
		"refId" => 1,
		"indetifier" => 1,
		"active" => [
			"REQUIRED" => true
		],
		"type" => [ 	
			"REQUIRED" => true
		],
		"name" => [
			"REQUIRED" => true
		],
		"alias" => 1,
		"telecom" => 1,
		"address" => 1,
		"partOf" => [
			"REQUIRED" => true
		],
		"send" => 1
	];
}