<?php
namespace BPJService\db\rencana_kontrol;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"noSurat" => 1
		, "jnsKontrol" => 1
		, "nomor" => 1
		, "tglRencanaKontrol" => 1
		, "kodeDokter" => 1		
		, "poliKontrol" => 1
		, "user" => 1
		, "status" => 1
	];
}
