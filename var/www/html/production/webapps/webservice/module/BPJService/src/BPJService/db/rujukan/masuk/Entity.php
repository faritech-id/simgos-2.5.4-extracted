<?php
namespace BPJService\db\rujukan\masuk;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"noKunjungan" => 1
		, "noKartu" => 1
		, "tglKunjungan" => 1
		, "provPerujuk" => 1
		, "diagnosa" => 1
		, "keluhan" => 1
		, "poliRujukan" => 1
		, "pelayanan" => 1
	];
}
