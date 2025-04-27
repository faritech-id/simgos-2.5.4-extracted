<?php
namespace Kemkes\IHS\V1\Rpc\Procedure;

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
		"bodySite" => 1,
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