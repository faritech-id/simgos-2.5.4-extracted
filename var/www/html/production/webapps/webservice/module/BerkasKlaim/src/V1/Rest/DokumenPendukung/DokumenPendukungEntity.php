<?php
namespace BerkasKlaim\V1\Rest\DokumenPendukung;
use DBService\SystemArrayObject;

class DokumenPendukungEntity extends SystemArrayObject
{
    protected $fields = [
        'ID'=>1
        , 'BERKAS'=>1
        , 'DESKRIPSI'=>1
        , 'DOKUMEN_PENDUKUNG'=>1
        , 'TANGGAL'=>1
        , 'STATUS'=>1
    ];
}
