<?php
namespace MedicalRecord\V1\Rest\AsuhanKeperawatan;
use DBService\SystemArrayObject;
class AsuhanKeperawatanEntity extends SystemArrayObject
{
    protected $fields = [
        "ID" => 1
        , "KUNJUNGAN" => 1
        , "SUBJECKTIF" => 1
        , "OBJEKTIF" => 1
        , "SUBJECT_MINOR" => 1
        , "OBJECT_MINOR" => 1
        , "FAKTOR_RESIKO" => 1
        , "DIAGNOSA" => 1
        , "PENYEBAP" => 1
        , "TUJUAN" => 1
        , "LAMA_INTEVENSI" => 1
        , "JENIS_LAMA_INTERVENSI" => 1
        , "INTERVENSI" => 1
        , "KRITERIA_HASIL" => 1
        , "OBSERVASI" => 1
        , "THEURAPEUTIC" => 1
        , "EDUKASI" => 1
        , "KOLABORASI" => 1
        , "DESK_DIAGNOSA" => 1
        , "DESK_TUJUAN" => 1
        , "DESK_INTERVENSI" => 1
        , "TANGGAL_INPUT" => 1        
        , "USER_VERIFIKASI" => 1
        , "TANGGAL_VERIFIKASI" => 1
        , "OLEH" => 1
        , "STATUS" => 1
    ];
}
