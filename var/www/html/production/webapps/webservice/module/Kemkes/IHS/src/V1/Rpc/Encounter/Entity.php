<?php
namespace Kemkes\IHS\V1\Rpc\Encounter;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"id" => 1,
		"refId" => 1,
		"indetifier" => 1,
		"status" => [
			"REQUIRED" => true
		],
		"class" => [
			"REQUIRED" => true
		],
		"subject" => [
			"REQUIRED" => true
		],
		"participant" => [
			"REQUIRED" => true
		],
		"period" => [
			"REQUIRED" => true
		],
		"location" => [
			"REQUIRED" => true
		],
		"diagnosis" => [
			"REQUIRED" => true
		],
		"statusHistory" => 1,
		"send" => 1
	];
}