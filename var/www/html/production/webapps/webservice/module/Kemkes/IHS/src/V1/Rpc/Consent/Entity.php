<?php
namespace Kemkes\IHS\V1\Rpc\Consent;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"id" => 1,
		"status" => 1,
		"scope" => 1,
		"category" => [
			"REQUIRED" => true
		],
		"patient" => [
			"REQUIRED" => true
		],
		"dateTime" => 1,
        "organization" => [
			"REQUIRED" => true
		],
		"policyRule" => [
			"REQUIRED" => true
		],
		"provision" => 1,
		"norm" => 1,
		"organization" => [
			"REQUIRED" => true
		],
		"bodySend"=> 1,
		"refId" => 1,
        "sendDate" => 1,
		"send" => 1
	];
}