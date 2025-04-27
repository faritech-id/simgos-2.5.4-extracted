<?php
namespace MedicalRecord\V1\Rest\TransfusiDarah;

use DBService\SystemArrayObject;


class TransfusiDarahEntity extends SystemArrayObject
{
    protected $fields = [
		"ID"=>1
        , "NORM"=>1
        , "NOPEN"=>1
        , "KUNJUNGAN"=>1
        , "SESUAI_PERMINTAAN"=>1
        , "JENIS_DARAH"=>1
        , "GOLOGAN_DARAH"=>1		
        , "JUMLAH_BAG"=>1
        , "JUMLAH_CC"=>1
        , "TANGGAL"=>1
        , "OLEH"=>1
        , "TANGGAL_FINAL"=>1
        , "STATUS"=>1
    ];
}
