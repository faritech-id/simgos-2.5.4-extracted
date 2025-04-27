<?php
namespace Kemkes\RSOnline\V1\Rest\RekapPasienKeluar;

use DBService\SystemArrayObject;

class RekapPasienKeluarEntity extends SystemArrayObject
{
    protected $fields = [
        "id" => [
            "isKey" => true
        ]
        , "tanggal" => 1
        , "sembuh" => 1
        , "discarded" => 1
        , 'meninggal_komorbid' => 1
        , 'meninggal_tanpa_komorbid' => 1
        , "meninggal_prob_pre_komorbid" => 1
        , "meninggal_prob_neo_komorbid" => 1
        , 'meninggal_prob_bayi_komorbid' => 1
        , 'meninggal_prob_balita_komorbid' => 1
        , "meninggal_prob_anak_komorbid" => 1
        , "meninggal_prob_remaja_komorbid" => 1
        , 'meninggal_prob_dws_komorbid' => 1
        , 'meninggal_prob_lansia_komorbid' => 1
        , "meninggal_prob_pre_tanpa_komorbid" => 1
        , "meninggal_prob_neo_tanpa_komorbid" => 1
        , 'meninggal_prob_bayi_tanpa_komorbid' => 1
        , 'meninggal_prob_balita_tanpa_komorbid' => 1
        , "meninggal_prob_anak_tanpa_komorbid" => 1
        , "meninggal_prob_remaja_tanpa_komorbid" => 1
        , 'meninggal_prob_dws_tanpa_komorbid' => 1
        , 'meninggal_prob_lansia_tanpa_komorbid' => 1
        , "meninggal_discarded_komorbid" => 1
        , "meninggal_discarded_tanpa_komorbid" => 1
        , 'dirujuk' => 1
        , 'isman' => 1
        , "aps" => 1
        , 'baru' => 1
        , 'tgl_kirim' => 1
        , 'kirim' => 1
        , 'response' => 1
    ];
}
