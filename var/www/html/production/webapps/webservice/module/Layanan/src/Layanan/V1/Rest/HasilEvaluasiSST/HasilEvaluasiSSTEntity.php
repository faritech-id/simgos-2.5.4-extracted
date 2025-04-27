<?php
namespace Layanan\V1\Rest\HasilEvaluasiSST;
USE DBService\SystemArrayObject;

class HasilEvaluasiSSTEntity extends SystemArrayObject
{
    protected $fields = [
        "ID" => 1
        , "KUNJUNGAN" => 1
        , "SELULARITAS" => 1
        , "ERITROPOIETIK" => 1
        , "LEUKOPOIETIK" => 1
        , "TROMBOPOIETIK" => 1
        , "SEL_PLASMA" => 1
        , "MITOSIS" => 1
        , "ME_RATIO" => 1
        , "KESAN" => 1
        , "DOKUMENT_ID_PERBESARAN_SEPULUH" => 1
        , "DOKUMENT_ID_PERBESARAN_SERATUS" => 1
        , "DOKUMENT_ID_PERBESARAN_SERATUS_DUA" => 1
        , "DOKTER" => 1
        , "TANGGAL" => 1
        , "STATUS" => 1
    ];
}
