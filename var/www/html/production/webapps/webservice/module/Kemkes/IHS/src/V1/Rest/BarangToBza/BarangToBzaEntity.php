<?php
namespace Kemkes\IHS\V1\Rest\BarangToBza;
use DBService\SystemArrayObject;

class BarangToBzaEntity extends SystemArrayObject
{
    protected $fields = [
        'ID' => 1
        , 'BARANG' => 1
        , 'KODE_BZA' => 1
        , 'DOSIS_KFA' => 1
        , 'SATUAN_DOSIS_KFA' => 1
        , 'DOSIS_PERSATUAN' => 1
        , 'SATUAN' => 1
        , 'STATUS' => 1
    ];
}