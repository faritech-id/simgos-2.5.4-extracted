<?php
namespace MedicalRecord\V1\Rest\Batuk;

use DBService\SystemArrayObject;

class BatukEntity extends SystemArrayObject
{
    protected $fields = [
		  "ID"=>1
		, "KUNJUNGAN"=>1
		, "DEMAM"=>1
		, "DEMAM_KETERANGAN"=>1
		, "BERKERINGAT_MALAM_HARI_TANPA_AKTIFITAS"=>1
		, "BERKERINGAT_MALAM_HARI_TANPA_AKTIFITAS_KETERANGAN"=>1
		, "BEPERGIAN_DARI_DAERAH_WABAH"=>1
		, "BEPERGIAN_DARI_DAERAH_WABAH_KETERANGAN"=>1
		, "PEMAKAIAN_OBAT_JANGKA_PANJANG"=>1
        , "PEMAKAIAN_OBAT_JANGKA_PANJANG_KETERANGAN"=>1
        , "BERAT_BADAN_TURUN_TANPA_SEBAB"=>1
		, "BERAT_BADAN_TURUN_TANPA_SEBAB_KETERANGAN"=>1
        , "TANGGAL"=>1
		, "OLEH"=>1
		, "STATUS"=>1
    ];
}
