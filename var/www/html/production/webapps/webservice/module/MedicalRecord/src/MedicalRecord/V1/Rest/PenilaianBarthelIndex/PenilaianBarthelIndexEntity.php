<?php
namespace MedicalRecord\V1\Rest\PenilaianBarthelIndex;

use DBService\SystemArrayObject;

class PenilaianBarthelIndexEntity extends SystemArrayObject {
    protected $fields = [
		"ID"=>1     
		, "KUNJUNGAN"=>1 
        , "PENDAFTARAN"=>1     
		, "TANGGAL"=>1 
		, "SEBELUM_SAKIT"=>1   
		, "KENDALI_RANGSANG_DEFEKASI"=>1  
		, "KENDALI_RANGSANG_KEMIH"=>1  
		, "BERSIH_DIRI"=>1  
		, "PENGGUNAAN_JAMBAN"=>1  
		, "MAKAN"=>1  
		, "PERUBAHAN_SIKAP"=>1  
		, "PINDAH_JALAN"=>1  
		, "PAKAI_BAJU"=>1     
		, "NAIK_TURUN_TANGGA"=>1     
		, "MANDI"=>1     
		, "DIBUAT_TANGGAL"=>1      
		, "OLEH"=>1     
		, "STATUS"=>1   
    ];
}

