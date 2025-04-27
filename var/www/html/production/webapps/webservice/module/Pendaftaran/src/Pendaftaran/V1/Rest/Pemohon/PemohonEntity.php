<?php
namespace Pendaftaran\V1\Rest\Pemohon;
use DBService\SystemArrayObject;
class PemohonEntity extends SystemArrayObject
{
    protected $fields = [
        "ID" => 1
        , "NIK" => 1
        , "NAMA" => 1
        , "ALAMAT" => 1
        , "KONTAK_HP" => 1
        , "KONTAK_EMAIL" => 1
        , "BAHASA" => 1
    ];
}
