<?php
namespace MedicalRecord\V1\Rest\TindakanAbci;
use DBService\SystemArrayObject;

class TindakanAbciEntity extends SystemArrayObject
{
    protected $fields = [
		"ID"=>1     
		,"KUNJUNGAN"=>1     
		,"AKTIF_BERLEBIHAN_DIRUMAH"=>1     
		,"MELUKAI_DIRI_TUJUAN_TERTENTU"=>1     
		,"LESUH_LEMAH_KURANG_AKTIF"=>1     
		,"AGRESIF_VERBAL_FISIK_ANAK_DEWASA"=>1     
		,"MENYENDIRI_DARI_ORANG_LAIN"=>1     
		,"PERGERAKAN_TUBUH_BERULANG_TIDAK_BERTUJUAN"=>1     
		,"RAMA_BERISIK_TANPA_ALASAN"=>1
		,"BERTERIAK_TANPA_ALASAN"=>1   
		,"BANYAK_BICARA"=>1
		,"TEMPER_TANTRUM"=>1     
		,"STEREOTIPLIK_TIDAK_NORMAL_BERULANG"=>1     
		,"MENATAP_LANGIT"=>1     
		,"IMPLUSIF"=>1     
		,"IRRITABLE"=>1     
		,"GELISA_TIDAK_DAPAT_DUDUK_DIAM"=>1     
		,"DOKTER"=>1     
		,"INTERPRETASI"=>1     
		,"ANJURAN"=>1     
		,"DIBUAT_TANGGAL"=>1
		,"OLEH"=>1     
		,"STATUS"=>1  
	];
}