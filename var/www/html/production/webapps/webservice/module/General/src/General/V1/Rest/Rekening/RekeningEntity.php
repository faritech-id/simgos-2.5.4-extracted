<?php
namespace General\V1\Rest\Rekening;
use DBService\SystemArrayObject;

class RekeningEntity extends SystemArrayObject
{
    protected $fields = [
        'ID' => 1,
        'BANK' => 1,
        'NOMOR' => 1,
        'PEMILIK' => 1,
        'JENIS' =>1,
        'STATUS' => 1
    ];
}
