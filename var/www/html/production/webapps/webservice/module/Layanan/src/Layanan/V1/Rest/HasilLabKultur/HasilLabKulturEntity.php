<?php
namespace Layanan\V1\Rest\HasilLabKultur;
use DBService\SystemArrayObject;

class HasilLabKulturEntity extends SystemArrayObject
{
    protected $fields = [
          'ID'=>1
        , 'KUNJUNGAN'=>1
        , 'BAHAN'=>1
        , 'GRAM'=>1
        , 'AEROB'=>1
        , 'KESIMPULAN'=>1
        , 'ANJURAN'=>1
        , 'CATATAN'=>1
        , 'TGL_HASIL'=>1
        , 'DOKTER'=>1
        , 'OLEH'=>1
        , 'STATUS'=>1
    ];
}
