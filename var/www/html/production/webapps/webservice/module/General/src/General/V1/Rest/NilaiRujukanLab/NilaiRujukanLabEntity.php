<?php
namespace General\V1\Rest\NilaiRujukanLab;
use DBService\SystemArrayObject;
class NilaiRujukanLabEntity extends SystemArrayObject
{
    protected $fields = [
        'ID' => 1
        , 'PARAMETER_TINDAKAN' => 1
        , 'JENIS_KELAMIN' => 1
        , 'UMUR' => 1
        , 'BATAS_BAWAH' => 1
        , 'BATAS_ATAS' => 1
        , 'OLEH' => 1
        , 'STATUS' => 1
    ];
}
