<?php
namespace Kemkes\IHS\V1\Rpc\Composition;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"id" => 1,
        "identifier" => 1,
		"status" => [
			"REQUIRED" => true
		],
		"type" => [
			"REQUIRED" => true
		],
        "category" => 1,
		"subject" => [
			"REQUIRED" => true
		],
		"encounter" => [
			"REQUIRED" => true
		],
        "date" => [
			"REQUIRED" => true
		],
        "author" => [
			"REQUIRED" => true
		],
		"title" => [
			"REQUIRED" => true
		],
		"confidentiality" => 1,
		"attester" => 1,
		"custodian" => [
			"REQUIRED" => true
		],
        "relatesTo" => 1,
        "event" => 1,
        "section" => [
			"REQUIRED" => true
		],
        "refId" => 1,
        "nopen" => 1,
        "sendDate" => 1,
		"send" => 1
	];
}