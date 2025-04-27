<?php
namespace Pembatalan\V1\Rest\FinalHasil;

use DBService\SystemArrayObject;

class FinalHasilEntity extends SystemArrayObject
{
	protected $fields = [
        'ID'=>1
        , 'KUNJUNGAN'=>1
        , 'REF'=>1
        , 'ALASAN'=>1
        , 'TANGGAL'=>1
        , 'OLEH'=>1
    ];
}
