<?php
namespace Kemkes\db\siranap\ruangan\simrs_kemkes;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = array(
		"ID" => 1
		, "RUANGAN" => 1
		, "KEMKES_RUANGAN" => 1
		, "STATUS" => 1
	);
}
