<?php
namespace Kemkes\IHS\V1\Rpc\AllergyIntolerance;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"id" => 1,
        "identifier" => 1,
		"clinicalStatus" => 1,
		"verificationStatus" => 1,
        "category" => 1,
		"code" => 1,
		"patient" => 1,
        "encounter" => 1,
        "recordedDate" => 1,
		"recorder" => 1,
        "refId" => 1,
        "nopen" => 1,
        "sendDate" => 1,
		"send" => 1
	];
}