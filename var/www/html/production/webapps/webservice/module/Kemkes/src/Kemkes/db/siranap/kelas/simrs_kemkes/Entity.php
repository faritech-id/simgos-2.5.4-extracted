<?php
namespace Kemkes\db\siranap\kelas\simrs_kemkes;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = array(
		"ID" => 1
		, "KELAS" => 1
		, "KEMKES_KELAS" => 1
		, "STATUS" => 1
	);
}
