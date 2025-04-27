<?php
namespace Kemkes\IHS\V1\Rpc\Specimen;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"id" => 1,
        "identifier" => 1,
		"accesssionIdentifier" => 1,
		"status" => 1,
		"type" => [
			"REQUIRED" => true
		],
		"subject" => [
			"REQUIRED" => true
		],
		"receivedTime" => 1,
		"parent" => 1,
		"request" => [
			"REQUIRED" => true
		],
		"collection" => 1,
		"processing" => [
			"REQUIRED" => true
		],
        "container" => 1,
        "condition" => 1,
        "note" => 1,
        "refId" => 1,
        "nopen" => 1,
        "sendDate" => 1,
		"send" => 1
	];
}
