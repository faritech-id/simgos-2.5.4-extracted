<?php
namespace MedicalRecord\V1\Rest\VerifikasiCPPT;
use DBService\SystemArrayObject;
class VerifikasiCPPTEntity extends SystemArrayObject
{
    protected $fields = [
        "ID" => 1,
        "KUNJUNGAN" => 1,
        "BATAS_TANGGAL" => 1,
        "OLEH" => 1,
        "STATUS" => 1
    ];
}
