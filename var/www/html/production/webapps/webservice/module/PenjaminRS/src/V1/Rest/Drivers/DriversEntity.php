<?php
namespace PenjaminRS\V1\Rest\Drivers;
use DBService\SystemArrayObject;
class DriversEntity extends SystemArrayObject
{
    protected $fields = [
        "ID" => 1
        , "JENIS_DRIVER_ID" => 1
        , "JENIS_PENJAMIN_ID" => 1
        , "CLASS" => 1
    ];
}
