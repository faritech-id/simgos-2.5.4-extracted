<?php
namespace Layanan\V1\Rest\HasilLabMikroskopik;
use DBService\SystemArrayObject;

class HasilLabMikroskopikEntity extends SystemArrayObject
{
    protected $fields = [
        'ID'=>1
        , 'KUNJUNGAN'=>1
        , 'BAHAN'=>1
        , 'DIAGNOSA'=>1
        , 'TERAPI_ANTIBIOTIK'=>1
        , 'TANGGAL_HASIL'=>1
        , 'DOKTER'=>1
        , 'OLEH'=>1
        , 'STATUS'=>1
    ];
}
