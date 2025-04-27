<?php
namespace BPJService\db\rujukan\khusus;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"noRujukan" => 1
		, "idRujukan" => 1
		, "diagnosa" => 1
		, "procedure" => 1
		, "user" => 1
		, "tglrujukan_awal" => 1
		, "tglrujukan_berakhir" => 1
		, "status" => 1
	];
}
