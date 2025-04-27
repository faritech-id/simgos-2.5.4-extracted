<?php
namespace MedicalRecord\V1\Rest\PemeriksaanEmg;

use DBService\SystemArrayObject;
class PemeriksaanEmgEntity extends SystemArrayObject
{
    protected $fields = [
		"ID"=>1     
		,"KUNJUNGAN"=>1     
		,"KELUHAN"=>1     
		,"PENGOBATAN"=>1     
		,"TD"=>1     
		,"RR"=>1     
		,"HR"=>1     
		,"DERAJAT_CELCIUS"=>1     
		,"GCS"=>1     
		,"NPRS"=>1     
		,"FKL"=>1
		,"NN_CRANIALIS"=>1     
		,"RCT_RCTL"=>1
		,"NN_CR_LAIN"=>1
		,"MOTORIK"=>1     
		,"PERGERAKAN"=>1     
		,"KEKUATAN"=>1     
		,"EXTREMITAS_SUPERIOR"=>1     
		,"EXTREMITAS_INFERIOR"=>1
		,"TONUS"=>1     
		,"REFLEKS_FISOLOGIS"=>1     
		,"REFLEKS_PATOLOGIS"=>1     
		,"SENSORIK"=>1     
		,"OTONOM"=>1        
		,"NVC_AND_EMG_FINDINGS"=>1
		,"IMPRESSION"=>1
		,"DOKTER"=>1
		,"SARAN"=>1
		,"DIBUAT_TANGGAL"=>1
		,"OLEH"=>1     
		,"STATUS"=>1  
	];
}
