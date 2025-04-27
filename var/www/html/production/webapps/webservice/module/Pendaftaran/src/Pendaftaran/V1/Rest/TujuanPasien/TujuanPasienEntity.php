<?php
namespace Pendaftaran\V1\Rest\TujuanPasien;
use DBService\SystemArrayObject;

class TujuanPasienEntity extends SystemArrayObject
{
    protected $fields = [
        'NOPEN' => 1,
        'RUANGAN' => 1,
        'RESERVASI' => 1,
        'SMF' => 1,
        'DOKTER' => 1,
        'IKUT_IBU' => 1,
        'KUNJUNGAN_IBU' => 1,
        'STATUS' => 1
    ];
}
