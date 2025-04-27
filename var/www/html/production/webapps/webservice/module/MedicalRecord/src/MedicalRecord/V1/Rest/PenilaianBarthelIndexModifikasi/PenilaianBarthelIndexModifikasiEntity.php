<?php
namespace MedicalRecord\V1\Rest\PenilaianBarthelIndexModifikasi;
use DBService\SystemArrayObject;

class PenilaianBarthelIndexModifikasiEntity extends SystemArrayObject {
    protected $fields = [
		"ID"=>1     
		, "KUNJUNGAN"=>1 
        , "KESADARAN"=>1     
		, "OBSERVASI_TTV"=>1 
		, "PERNAPASAN"=>1   
		, "KEBERSIHAN_DIRI_DAN_BERPAKAIAN"=>1  
		, "MAKAN_DAN_MINUM"=>1  
		, "PENGOBATAN"=>1  
		, "MOBILISASI"=>1  
		, "ELIMINASI"=>1  
		, "TANGGAL_PENILAIAN"=>1  
		, "SKOR_SEBELUM_SAKIT"=>1  
		, "DIBUAT_TANGGAL"=>1      
		, "OLEH"=>1     
		, "STATUS"=>1   
    ];
}

