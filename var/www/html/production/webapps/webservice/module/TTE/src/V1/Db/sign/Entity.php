<?php
namespace TTE\V1\Db\sign;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
    protected $fields = [
        "ID" => 1
        , "PROVIDER_ID" => 1
        , "PROVIDER_REF_ID" => 1
        , "TTD_OLEH" => 1
        , "TTD_TANGGAL" => 1
        , "REF_ID" => 1
        , "REF_JENIS" => 1
    ];
}
