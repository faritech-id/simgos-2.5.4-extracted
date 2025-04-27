<?php
namespace BPJService\db\map_kelas;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = array(
		"id" => 1
        , "kelas" => 1
        , "kelas_rs" => 1
        , "status" => 1
	);
}
