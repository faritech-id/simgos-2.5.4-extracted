<?php
namespace Kemkes\V2\Rest\TerkonfirmasiTB;
use DBService\SystemArrayObject;
class TerkonfirmasiTBEntity extends SystemArrayObject
{
    protected $fields = [
        "ID" => 1
        , "NORM" => 1
        , "KUNJUNGAN" => 1
        , "TANGGAL" => 1
        , "STATUS" =>  1
    ];
}
