<?php
namespace Kemkes\IHS\V1\Rpc\MedicationDispanse;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"id" => 1,
        "identifier" => 1,
		"partOf" => 1,
		"status" => [
			"REQUIRED" => true
		],
		"category" => [
			"REQUIRED" => true
		],
		"medicationReference" => [
			"REQUIRED" => true
		],
		"subject" => [
			"REQUIRED" => true
		],
		"context" => [
			"REQUIRED" => true
		],
		"performer" => 1,
		"location" => [
			"REQUIRED" => true
		],
		"authorizingPrescription" => 1,
		"quantity" => [
			"REQUIRED" => true
		],
		"daysSupply" => 1,
		"whenPrepared" => 1,
		"whenHandedOver" => 1,
		"dosageInstruction" => [
			"REQUIRED" => true
		],
		"substitution" =>1,
        "refId" => 1,
        "barang" => 1,
        "group_racikan" => 1,
        "nopen" => 1,
		"status_racikan" => 1,
        "sendDate" => 1,
		"send" => 1
	];
}