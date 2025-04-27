<?php
namespace Kemkes\IHS\V1\Rpc\Patient;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"id" => 1,
		"refId" => 1,
		'identifier' => 1,
		"active" => 1,
		"address" => 1,
		"birthDate" => 1,
		"communication" => 1,
		"deceasedBoolean" => 1,
		"extension" => 1,
		"gender" => 1,
		"maritalStatus" => 1,
		"meta" => 1,
		"multipleBirthBoolean" => 1,
		"name" => 1,
		"telecom" => 1,
		"refId" => 1,
		"nik" => 1,
		"getDate" => 1,
		"httpRequest" => 1,
		"statusRequest" => 1
	];
}