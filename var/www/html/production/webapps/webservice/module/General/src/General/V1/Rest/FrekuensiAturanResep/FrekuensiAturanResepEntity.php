<?php
namespace General\V1\Rest\FrekuensiAturanResep;
use DBService\SystemArrayObject;

class FrekuensiAturanResepEntity extends SystemArrayObject
{
	protected $fields = [
		"ID" => 1
		, "FREKUENSI" => 1
		, "SIGNA1" => 1
        , "SIGNA2" => 1
        , "KETERANGAN" => 1
        , "STATUS" => 1
	];
}
