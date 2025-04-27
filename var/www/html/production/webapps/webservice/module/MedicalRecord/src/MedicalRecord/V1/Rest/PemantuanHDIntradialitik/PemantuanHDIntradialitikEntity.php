<?php
namespace MedicalRecord\V1\Rest\PemantuanHDIntradialitik;
use DBService\SystemArrayObject; 
class PemantuanHDIntradialitikEntity extends SystemArrayObject
{
    protected $fields = [
        "ID" => 1,
        "KUNJUNGAN" => 1,
        "QUICK_BLOOD" => 1,
        "QUICK_DIALISIS" => 1,
        "ULTRA_FILTRASI_VOLUME" => 1,
        "ULTRA_FILTRASI_RATE" => 1,
        "WAKTU_PEMERIKSAAN" => 1,
        "TANGGAL" => 1,
        "OLEH" => 1,
        "STATUS" => 1
    ];
}
