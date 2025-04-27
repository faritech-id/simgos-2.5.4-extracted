<?php
namespace Aplikasi\V1\Rest\PropertiConfig;

use DBService\SystemArrayObject;

class PropertiConfigEntity extends SystemArrayObject
{
    protected $fields = [
		"ID" => 1
        , "NAMA" => 1
        , "VALUE" => 1
        , "DESKRIPSI" => 1
    ];
}
