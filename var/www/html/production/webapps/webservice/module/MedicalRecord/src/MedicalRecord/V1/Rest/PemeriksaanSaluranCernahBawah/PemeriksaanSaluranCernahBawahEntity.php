<?php
namespace MedicalRecord\V1\Rest\PemeriksaanSaluranCernahBawah;
use DBService\SystemArrayObject;

class PemeriksaanSaluranCernahBawahEntity extends SystemArrayObject
{
    protected $fields = [
		"ID"=>1     
		,"KUNJUNGAN"=>1     
		,"ADA_KELAINAN"=>1     
		,"RASA_TIDAK_ENAK"=>1     
		,"RASA_PANAS"=>1     
		,"RASA_MELILIT"=>1     
		,"BIASA"=>1     
		,"LOKALISASI"=>1     
		,"BERHUBUNGAN_DENGAN_MAKAN"=>1  
        ,"BANGUN_TENGAH_MALAM_KARENA_NYERI"=>1     
		,"KEMBUNG"=>1     
		,"CEPAT_KENYANG"=>1     
		,"DESKRIPSI"=>1     
		,"TANGGAL"=>1     
		,"OLEH"=>1     
		,"STATUS"=>1     
	];
}
