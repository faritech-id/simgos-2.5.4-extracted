<?php
namespace Layanan\V1\Rest\NilaiKritisLab;
use DBService\SystemArrayObject;

class NilaiKritisLabEntity extends SystemArrayObject
{
    protected $fields = [
        "ID" => 1
        , "HASIL_LAB" => 1
        , "PELAPOR" => 1
        , "PENERIMA" => 1
        , "STATUS_LAPOR" => 1
        , "WAKTU_LAPOR" => 1
        , "KETERANGAN" => 1
        , "TANGGAL" => 1
        , "OLEH" => 1
        , "STATUS" => 1
    ];
}
