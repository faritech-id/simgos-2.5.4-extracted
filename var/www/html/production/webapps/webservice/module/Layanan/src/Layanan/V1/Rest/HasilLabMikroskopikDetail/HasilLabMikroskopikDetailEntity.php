<?php
namespace Layanan\V1\Rest\HasilLabMikroskopikDetail;
use DBService\SystemArrayObject;

class HasilLabMikroskopikDetailEntity extends SystemArrayObject
{
    protected $fields = [
        'ID'=>1
        , 'KUNJUNGAN'=>1
        , 'PEMERIKSAAN'=>1
        , 'HASIL'=>1
        , 'TIMESTAMP'=>1
        , 'OLEH'=>1
        , 'STATUS'=>1
    ];
}
