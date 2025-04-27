<?php
namespace Layanan\V1\Rest\HasilLabPCR;
use DBService\SystemArrayObject;

class HasilLabPCREntity extends SystemArrayObject
{
    protected $fields = [
        'ID'=>1
        , 'KUNJUNGAN'=>1
        , 'BAHAN'=>1
        , 'DIAGNOSA'=>1
        , 'TERAPI_ANTIBIOTIK'=>1
        , 'HASIL'=>1
        , 'KESIMPULAN'=>1
        , 'ANJURAN'=>1
        , 'CATATAN'=>1
        , 'TANGGAL_HASIL'=>1
        , 'DOKTER'=>1
        , 'OLEH'=>1
        , 'STATUS'=>1
    ];
}
