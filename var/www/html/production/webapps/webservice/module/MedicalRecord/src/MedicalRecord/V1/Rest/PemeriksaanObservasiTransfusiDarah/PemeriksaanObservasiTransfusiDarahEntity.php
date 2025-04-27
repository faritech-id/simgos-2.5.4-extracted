<?php
namespace MedicalRecord\V1\Rest\PemeriksaanObservasiTransfusiDarah;
use DBService\SystemArrayObject;
class PemeriksaanObservasiTransfusiDarahEntity extends SystemArrayObject
{
    protected $fields = [
        "ID"=>1
        , "KUNJUNGAN"=>1
        , "NOMOR_BAG_DARAH"=>1
        , "REAKSI_LAMBAT"=>1
        , "REAKSI_TRANSFUSI"=>1		
        , "PERUBAHAN_KONDISI_PASIEN"=>1
        , "TTV"=>1
        , "TANGGAL_INPUT"=>1
        , "TANGGAL"=>1
        , "OLEH"=>1
        , "STATUS"=>1
    ];
}
