<?php
namespace BPJService\db\lpk;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"noSep" => 1
		, "tglMasuk" => 1
		, "tglKeluar" => 1
		, "jaminan" => 1
		, "poli" => 1		
		, "perawatan" => 1
		, "diagnosa" => 1
		, "procedure" => 1
		, "rencanaTL" => 1
		, "DPJP" => 1
		, "user" => 1
		, "status" => 1
	];
}
