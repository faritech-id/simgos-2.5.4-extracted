<?php
namespace Kemkes\IHS\V1\Rpc\Location;

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
		"operationalStatus" => 1,
		"name" => [
			"REQUIRED" => true
		],
		"alias" => 1,
		"description" => 1,
		"mode" => 1,
		"type" => 1,
		"telecom" => 1,
		"address" => 1,
		"physicalType" => [
			"REQUIRED" => true
		],
		"position" => 1,
		"partOf" => [
			"REQUIRED" => true
		],
		"managingOrganization" => [
			"REQUIRED" => true
		],
		"hoursOfOperation" => 1,
		"send" => 1
	];
}