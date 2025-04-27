<?php
namespace PenjaminRS\V1\Rest\CaraKeluar;

use DBService\SystemArrayObject;

class CaraKeluarEntity extends SystemArrayObject
{
    protected $fields = [
        "ID" => 1
        , "PENJAMIN" => 1
        , "KODE_PENJAMIN" => 1
        , "KODE_RS" => 1
        , "TANGGAL" => 1
        , "STATUS" => 1
    ];
}
