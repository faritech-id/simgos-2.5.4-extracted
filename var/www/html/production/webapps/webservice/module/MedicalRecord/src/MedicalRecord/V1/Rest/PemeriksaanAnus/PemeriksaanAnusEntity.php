<?php
namespace MedicalRecord\V1\Rest\PemeriksaanAnus;

use DBService\SystemArrayObject;

class PemeriksaanAnusEntity extends SystemArrayObject {
    protected $fields = [
		"ID"=>1     
		,"KUNJUNGAN"=>1     
		,"PENDAFTARAN"=>1     
		,"ADA_KELAINAN"=>1     
		,"INSPEKSI_SEKITAR_ANUS"=>1
		,"SPINKTER_ANI"=>1
		,"MUKOSA"=>1
		,"NYERI"=>1
		,"LOKASI_NYERI"=>1
		,"MASSA_TUMOR"=>1
		,"UKURAN"=>1
		,"KONSISTENSI"=>1
		,"AMPULLA"=>1
		,"FASES"=>1
		,"DARAH"=>1
		,"LENDIR"=>1
		,"DESKRIPSI"=>1
		,"TANGGAL"=>1     
		,"OLEH"=>1     
		,"STATUS"=>1  
	];
}
