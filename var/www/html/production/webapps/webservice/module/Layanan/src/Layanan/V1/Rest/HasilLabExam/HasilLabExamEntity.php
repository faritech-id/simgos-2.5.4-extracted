<?php
namespace Layanan\V1\Rest\HasilLabExam;
use DBService\SystemArrayObject;

class HasilLabExamEntity extends SystemArrayObject
{
    protected $fields = [
        'ID'=>1
        , 'KUNJUNGAN'=>1
        , 'DATE_SP1'=>1
        , 'DATE_SP2'=>1
        , 'DATE_SP3'=>1
        , 'ACID_DATE'=>1
        , 'ACID_SP1'=>1
        , 'ACID_SP2'=>1
        , 'ACID_SP3'=>1
        , 'LJ_DATE'=>1
        , 'LJ_SP1'=>1
        , 'LJ_SP2'=>1
        , 'LJ_SP3'=>1
        , 'MGIT_DATE'=>1
        , 'MGIT_SP1'=>1
        , 'MGIT_SP2'=>1
        , 'MGIT_SP3'=>1
        , 'ANTITUBE'=>1
        , 'CONCLUSION'=>1
        , 'DOKTER'=>1
        , 'OLEH'=>1
        , 'STATUS'=>1
    ];
}
