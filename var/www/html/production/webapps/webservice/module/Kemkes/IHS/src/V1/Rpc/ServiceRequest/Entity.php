<?php
namespace Kemkes\IHS\V1\Rpc\ServiceRequest;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"id" => 1,
        "identifier" => 1,
		"basedOn" => 1,
		"replaces" => 1,
		"requisition" => 1,
		"status" => [
			"REQUIRED" => true
		],
		"intent" => [
			"REQUIRED" => true
		],
		"category" => 1,
		"priority" => 1,
		"doNotPerform" => 1,
		"code" => [
			"REQUIRED" => true
		],
        "orderDetail" => 1,
        "quantity" => 1,
        "subject" => [
			"REQUIRED" => true
		],
        "encounter" => [
			"REQUIRED" => true
		],
        "occurence" => 1,
        "asNeeded" => 1,
        "occurrenceDateTime" => 1,
        "authoredOn" => 1,
        "requester" => 1,
        "performerType" => 1,
        "performer" => 1,
        "locationCode" => 1,
        "locationReference" => 1,
        "reasonCode" => 1,
        "reasonReference" => 1,
        "insurance" => 1,
        "supportingInfo" => 1,
        "specimen" => 1,
        "bodySite" => 1,
        "note" => 1,
        "patientInstruction" => 1,
        "relevantHistory" => 1,
        "refId" => 1,
        "nopen" => 1,
        "sendDate" => 1,
		"send" => 1
	];
}