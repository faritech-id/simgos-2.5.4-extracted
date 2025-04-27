<?php
namespace Kemkes\IHS\V1\Rest\POA;
use DBService\SystemArrayObject;

class POAEntity extends SystemArrayObject
{
    protected $fields = [
        'id' => 1
        , 'display' => 1
        , 'pov' => 1
        , 'nama_dagang' => 1
        , 'unit_logistik_terkecil' => 1
        , 'bentuk_sediaan' => 1
        , 'id_bentuk_sediaan' => 1
        , 'golongan_obat' => 1
        , 'url' => 1
        , 'status' => 1
    ];
}
