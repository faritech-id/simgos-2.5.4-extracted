<?php
namespace Kemkes\IHS\V1\Rest\BarangToPoaPov;
use DBService\SystemArrayObject;

class BarangToPoaPovEntity extends SystemArrayObject
{
    protected $fields = [
        'BARANG' => 1
        , 'KODE_POA' => 1
        , 'KODE_POV' => 1
        , 'RUTE_OBAT' => 1
        , 'STATUS' => 1
    ];
}