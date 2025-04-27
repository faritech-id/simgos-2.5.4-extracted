<?php
namespace Kemkes\RSOnline\V1\Rest\DataTempatTidur;

use DBService\SystemArrayObject;

class DataTempatTidurEntity extends SystemArrayObject
{
	protected $fields = [
        "id" => 1
        , "id_tt" => 1
        , "ruang" => 1
        , "jumlah_ruang" => 1
        , "jumlah" => 1
        , 'terpakai' => 1
        , 'terpakai_suspek' => 1
        , 'terpakai_konfirmasi' => 1
        , 'prepare' => 1
        , 'prepare_plan' => 1
        , 'covid' => 1
        , 'baru' => 1
        , 'tgl_kirim' => 1
        , 'antrian' => 1
        , 'kirim' => 1
        , 'response' => 1
	];
}