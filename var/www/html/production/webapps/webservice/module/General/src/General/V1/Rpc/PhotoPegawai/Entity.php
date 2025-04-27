<?php
namespace General\V1\Rpc\PhotoPegawai;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
    protected $fields = array(
        "NIP" => 1
        , "DATA" => 1
        , "TIPE" => 1
    );
}
