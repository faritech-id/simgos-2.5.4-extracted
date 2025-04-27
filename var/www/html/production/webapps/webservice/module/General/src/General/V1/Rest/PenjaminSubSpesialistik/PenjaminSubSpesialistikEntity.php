<?php
namespace General\V1\Rest\PenjaminSubSpesialistik;

use DBService\SystemArrayObject;

class PenjaminSubSpesialistikEntity extends SystemArrayObject
{
    protected $fields = [
        "ID" => 1
        , "PENJAMIN" => 1
        , "SUB_SPESIALIS_PENJAMIN" => 1
        , "SUB_SPESIALIS_RS" => 1
        , "FINGER" => 1
        , "STATUS" => 1
    ];
}