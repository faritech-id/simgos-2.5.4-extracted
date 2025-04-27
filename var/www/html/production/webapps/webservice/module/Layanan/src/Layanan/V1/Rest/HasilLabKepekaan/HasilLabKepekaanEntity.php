<?php
namespace Layanan\V1\Rest\HasilLabKepekaan;
use DBService\SystemArrayObject;

class HasilLabKepekaanEntity extends SystemArrayObject
{
    protected $fields = [
        'ID'=>1
        , 'KUNJUNGAN'=>1
        , 'BAKTERI'=>1
        , 'ANTIBIOTIK'=>1
        , 'HASIL'=>1
        , 'TANGGAL'=>1
        , 'OLEH'=>1
        , 'STATUS'=>1
    ];
}
