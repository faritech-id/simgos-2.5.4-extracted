<?php
namespace Kemkes\RSOnline\V1\Rest\RekapPasienNonKomorbid;

use DBService\SystemArrayObject;

class RekapPasienNonKomorbidEntity extends SystemArrayObject
{
    protected $fields = [
        "id" => [
            "isKey" => true
        ]
        , "tanggal" => 1
        , "icu_dengan_ventilator_suspect_l" => 1
        , "icu_dengan_ventilator_suspect_p" => 1
        , 'icu_dengan_ventilator_confirm_l' => 1
        , 'icu_dengan_ventilator_confirm_p' => 1
        , "icu_tanpa_ventilator_suspect_l" => 1
        , "icu_tanpa_ventilator_suspect_p" => 1
        , 'icu_tanpa_ventilator_confirm_l' => 1
        , 'icu_tanpa_ventilator_confirm_p' => 1
        , "icu_tekanan_negatif_dengan_ventilator_suspect_l" => 1
        , "icu_tekanan_negatif_dengan_ventilator_suspect_p" => 1
        , 'icu_tekanan_negatif_dengan_ventilator_confirm_l' => 1
        , 'icu_tekanan_negatif_dengan_ventilator_confirm_p' => 1
        , "icu_tekanan_negatif_tanpa_ventilator_suspect_l" => 1
        , "icu_tekanan_negatif_tanpa_ventilator_suspect_p" => 1
        , 'icu_tekanan_negatif_tanpa_ventilator_confirm_l' => 1
        , 'icu_tekanan_negatif_tanpa_ventilator_confirm_p' => 1
        , "isolasi_tekanan_negatif_suspect_l" => 1
        , "isolasi_tekanan_negatif_suspect_p" => 1
        , 'isolasi_tekanan_negatif_confirm_l' => 1
        , 'isolasi_tekanan_negatif_confirm_p' => 1
        , "isolasi_tanpa_tekanan_negatif_suspect_l" => 1
        , "isolasi_tanpa_tekanan_negatif_suspect_p" => 1
        , 'isolasi_tanpa_tekanan_negatif_confirm_l' => 1
        , 'isolasi_tanpa_tekanan_negatif_confirm_p' => 1
        , "nicu_khusus_covid_suspect_l" => 1
        , "nicu_khusus_covid_suspect_p" => 1
        , 'nicu_khusus_covid_confirm_l' => 1
        , 'nicu_khusus_covid_confirm_p' => 1
        , "picu_khusus_covid_suspect_l" => 1
        , "picu_khusus_covid_suspect_p" => 1
        , 'picu_khusus_covid_confirm_l' => 1
        , 'picu_khusus_covid_confirm_p' => 1
        , 'baru' => 1
        , 'tgl_kirim' => 1
        , 'kirim' => 1
        , 'response' => 1
    ];
}
