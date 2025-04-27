<?php
namespace MedicalRecord\V1\Rest\RiwayatGynekologi;
use DBService\SystemArrayObject;
class RiwayatGynekologiEntity extends SystemArrayObject
{
    protected $fields = [
        "ID"=>1
		, "KUNJUNGAN"=>1
        , "INFERTILITAS"=> 1
        , "INFEKSI_VIRUS"=> 1
        , "PENYAKIT_MENULAR_SEKSUAL"=> 1
        , "CERVISITIS_CRONIS"=> 1
        , "ENDOMETRIOSIS"=> 1
        , "MYOMA"=> 1
        , "POLIP_SERVIX"=> 1
        , "KANKER_KANDUNGAN"=> 1
        , "MINUMAN_ALKOHOL"=> 1
        , "PERKOSAAN"=> 1
        , "OPERASI_KANDUNGAN"=> 1
        , "POST_COINTAL_BLEEDING"=> 1
        , "FLOUR_ALBUS"=> 1
        , "LAINYA"=> 1
        , "KETERANGAN_LAINNYA"=> 1
        , "GATAL"=> 1
        , "BERBAU"=> 1
        , "WARNAH"=> 1
        , "TANGGAL"=> 1
        , "OLEH"=> 1
        , "STATUS"=> 1
    ];
}
