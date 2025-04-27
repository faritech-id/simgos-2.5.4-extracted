<?php
namespace Kemkes\IHS\V1\Rpc\Medication;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"id" => 1,
        "identifier" => 1,
		"code" => [
			"REQUIRED" => true
		],
		"status" => [
			"REQUIRED" => true
		],
		"manufacturer" => 1,
		"form" => [
			"REQUIRED" => true
		],
		"ingredient" => 1,
		"batch" => 1,
		"extension" => [
			"REQUIRED" => true
		],
        "refId" => 1,
        "barang" => 1,
		"group_racikan" => 1,
        "nopen" => 1,
		"status_racikan" => 1,
        "jenis" => 1,
        "sendDate" => 1,
		"send" => 1
	];
}