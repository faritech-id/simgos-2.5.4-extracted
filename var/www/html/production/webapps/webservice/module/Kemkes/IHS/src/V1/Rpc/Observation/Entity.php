<?php
namespace Kemkes\IHS\V1\Rpc\Observation;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"id" => 1,
		"status" => [
			"REQUIRED" => true
		],
		"category" => [
			"REQUIRED" => true
		],
		"code" => [
			"REQUIRED" => true
		],
		"subject" => [
			"REQUIRED" => true
		],
		"encounter" => [
			"REQUIRED" => true
		],
		"effectiveDateTime" => [
			"REQUIRED" => true
		],
		"issued" => 1,
		"performer"=> 1,
		"specimen"=> 1,
		"basedOn"=> 1,
		"valueString"=> 1,
		"bodySite" => 1,
		"derivedFrom" => 1,
		"valueQuantity" => [
			"REQUIRED" => true
		],
		"interpretation" => 1,
        "refId" => 1,
        "jenis" => 1,
        "nopen" => 1,
        "sendDate" => 1,
		"send" => 1
	];
}