<?php
namespace Aplikasi\V1\Rest\Petunjuk;

use DBService\SystemArrayObject;

class PetunjukEntity extends SystemArrayObject
{
    protected $fields = [
		"ID" => 1
        , "LEVEL" => 1
        , "JUDUL" => 1
        , "DESKRIPSI" => 1
        , "URL" => 1
        , "CONFIG" => 1
        , "IDX" => 1
        , "STATUS" => 1
    ];
}
