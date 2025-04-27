<?php
namespace MedicalRecord\V1\Rest\HubunganPsikososialEndOfLife;

use DBService\SystemArrayObject;

class HubunganPsikososialEndOfLifeEntity extends SystemArrayObject
{
    protected $fields = [
        "ID"=>1
        , "KUNJUNGAN"=>1
        , "KECEMASAN_PASIEN_ATAU_KERABAT"=>1
        , "KETERANGAN_KECEMASAN_PASIEN_ATAU_KERABAT"=>1
        , "KEBUTUHAN_DAN_DUKUNGAN_SPIRITUAL"=>1
        , "KETERANGAN_KEBUTUHAN_DAN_DUKUNGAN_SPIRITUAL"=>1
        , "DUKUNGAN_DARI_TIM"=>1
        , "KETERANGAN_DUKUNGAN_DARI_TIM"=>1
        , "INDIKASI_TRADISI_KEAGAMAAN"=>1
        , "KETERANGAN_INDIKASI_TRADISI_KEAGAMAAN"=>1
        , "INDIKASI_KEBUTUHAN_KHUSUS"=>1
        , "KETERANGAN_INDIKASI_KEBUTUHAN_KHUSUS"=>1
        , "PILIHAN_HIDUP_PASIEN"=>1
        , "TANGGAL"=>1
        , "OLEH"=>1
        , "STATUS"=>1
    ];
}
