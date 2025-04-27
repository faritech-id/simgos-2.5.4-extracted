<?php
namespace PenjaminRS\V1\Rest\Dpjp;

use DBService\SystemArrayObject;

class DpjpEntity extends SystemArrayObject
{
    protected $fields = [
        "ID" => 1
        , "PENJAMIN" => 1
        , "DPJP_PENJAMIN" => 1
        , "DPJP_RS" => 1
        , "TANGGAL" => 1
        , "STATUS" => 1
    ];
}
