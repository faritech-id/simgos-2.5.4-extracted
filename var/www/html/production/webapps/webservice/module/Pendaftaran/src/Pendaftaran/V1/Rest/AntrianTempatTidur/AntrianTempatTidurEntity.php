<?php
namespace Pendaftaran\V1\Rest\AntrianTempatTidur;
use DBService\SystemArrayObject;

class AntrianTempatTidurEntity extends SystemArrayObject
{
    protected $fields = [
        "ID" => 1
        , "NORM" => 1
        , "TANGGAL" => 1
        , "RENCANA_RUANGAN" => 1
        , "RENCANA_KELAS" => 1
        , "RENCANA_RUANGAN_ALTERNATIF" => 1
        , "RENCANA_KELAS_ALTERNATIF" => 1
        , "PRIORITAS" => 1
        , "DIAGNOSA" => 1
        , "DPJP" => 1
        , "PEMOHON_ID" => 1
        , "RESERVASI_NOMOR" => 1
        , "STATUS" => 1
    ];
}
