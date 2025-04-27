<?php
namespace BPJService\db\prb;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"noSRB" => 1
		, "noSep" => 1
		, "noKartu" => 1
		, "alamat" => 1
		, "email" => 1		
		, "programPRB" => 1
		, "kodeDPJP" => 1
		, "keterangan" => 1
		, "saran" => 1
		, "obat" => 1
		, "tglSRB" => 1
		, "user" => 1
		, "status" => 1
	];
}
