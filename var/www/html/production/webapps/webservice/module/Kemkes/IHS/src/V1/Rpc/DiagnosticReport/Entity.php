<?php
namespace Kemkes\IHS\V1\Rpc\DiagnosticReport;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"id" => 1,
        "identifier" => 1,
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
        "resultInterpreter"=> 1,
		"basedOn"=> 1,
		"valueString"=> 1,
		"result" => 1,
		"imagingStudy" => 1,
		"media" => 1,
		"conclusion" => 1,
		"conclusionCode" => 1,
		"presentedForm" => 1,
        "refId" => 1,
        "nopen" => 1,
        "sendDate" => 1,
		"send" => 1
	];
}