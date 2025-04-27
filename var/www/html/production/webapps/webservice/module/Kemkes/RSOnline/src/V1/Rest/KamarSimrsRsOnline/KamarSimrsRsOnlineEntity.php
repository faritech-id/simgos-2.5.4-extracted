<?php
namespace Kemkes\RSOnline\V1\Rest\KamarSimrsRsOnline;

use DBService\SystemArrayObject;

class KamarSimrsRsOnlineEntity extends SystemArrayObject
{
    protected $fields = [
        "id" => 1
        , "ruang_kamar" => 1
        , "tempat_tidur" => 1
        , "covid" => 1
        , "status" => 1
    ];
}
