<?php
namespace Kemkes\IHS\V1\Rpc\MedicationRequest;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"id" => 1,
        "identifier" => 1,
		"status" => [
			"REQUIRED" => true
		],
		"statusReason" => 1,
		"intent" => [
			"REQUIRED" => true
		],
		"category" => [
			"REQUIRED" => true
		],
		"priority" => 1,
		"reportedBoolean" => [
			"REQUIRED" => true
		],
		"medicationReference" => [
			"REQUIRED" => true
		],
		"subject" => [
			"REQUIRED" => true
		],
		"encounter" => [
			"REQUIRED" => true
		],
		"authoredOn" => [
			"REQUIRED" => true
		],
		"requester" => [
			"REQUIRED" => true
		],
		"performer" => 1,
		"performerType" => 1,
		"recorder" => 1,
		"reasonCode" =>1,
		"reasonReference" => 1,
		"basedOn" => 1,
		"courseOfTherapyType" => 1,
		"insurance" => 1,
		"note" => 1,
		"dosageInstruction" => [
			"REQUIRED" => true
		],
		"dispenseRequest" => [
			"REQUIRED" => true
		],
		"substitution" => 1,
        "refId" => 1,
        "barang" => 1,
        "group_racikan" => 1,
        "nopen" => 1,
		"status_racikan" => 1,
        "sendDate" => 1,
		"send" => 1
	];
}