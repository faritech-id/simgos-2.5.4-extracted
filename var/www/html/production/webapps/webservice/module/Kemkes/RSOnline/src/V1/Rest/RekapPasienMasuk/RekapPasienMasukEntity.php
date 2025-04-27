<?php
namespace Kemkes\RSOnline\V1\Rest\RekapPasienMasuk;

use DBService\SystemArrayObject;

class RekapPasienMasukEntity extends SystemArrayObject
{
        protected $fields = [
                "id" => [
                        "isKey" => true
                ]
                , "tanggal" => 1
                , "igd_suspect_l" => 1
                , "igd_suspect_p" => 1
                , 'igd_confirm_l' => 1
                , 'igd_confirm_p' => 1
                , "rj_suspect_l" => 1
                , "rj_suspect_p" => 1
                , 'rj_confirm_l' => 1
                , 'rj_confirm_p' => 1
                , "ri_suspect_l" => 1
                , "ri_suspect_p" => 1
                , 'ri_confirm_l' => 1
                , 'ri_confirm_p' => 1
                , 'baru' => 1
                , 'tgl_kirim' => 1
                , 'kirim' => 1
                , 'response' => 1
        ];
}