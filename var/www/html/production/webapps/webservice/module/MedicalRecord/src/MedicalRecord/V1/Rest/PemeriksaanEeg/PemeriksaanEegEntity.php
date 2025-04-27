<?php
namespace MedicalRecord\V1\Rest\PemeriksaanEeg;

use DBService\SystemArrayObject;
class PemeriksaanEegEntity extends SystemArrayObject
{
    protected $fields = [
		"ID"=>1     
		,"KUNJUNGAN"=>1     
		,"HASIL"=>1     
		,"HASIL_SEBELUMNYA"=>1
		,"MRI_KEPALA"=>1   
		,"HASIL_PEREKAMAN"=>1
		,"SARAN"=>1     
		,"DOKTER"=>1     
		,"KESIMPULAN"=>1     
		,"DIBUAT_TANGGAL"=>1
		,"OLEH"=>1     
		,"STATUS"=>1  
	];
}
