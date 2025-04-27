<?php
namespace Kemkes\IHS\V1\Rpc\Condition;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"id" => 1,
		"refId" => 1,
		"indetifier" => 1,
		"clinicalStatus" => [
			"REQUIRED" => true
		],
		"verificationStatus" => 1,
		"category" => [
			"REQUIRED" => true
		],
		"severity" => 1,
		"code" => [
			"REQUIRED" => true
		],
		"bodySite" => 1,
		"subject" => [
			"REQUIRED" => true
		],
		"encounter" => [
			"REQUIRED" => true
		],
		"hoursOfOperation" => 1,
		"send" => 1
	];
}