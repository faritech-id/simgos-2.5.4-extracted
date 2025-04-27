<?php
namespace General\V1\Rest\LockAksesPasien;
use DBService\SystemArrayObject;
class LockAksesPasienEntity extends SystemArrayObject
{
    protected $fields = [
        "NORM" => 1,
        "TANGGAL" => 1,
        "ALASAN" => 1,
        "JENIS" => 1,
        "OLEH" => 1,
        "STATUS" => 1
    ];
}
