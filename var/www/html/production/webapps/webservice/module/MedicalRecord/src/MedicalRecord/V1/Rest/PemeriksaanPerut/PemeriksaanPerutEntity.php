<?php
namespace MedicalRecord\V1\Rest\PemeriksaanPerut;

use DBService\SystemArrayObject;

class PemeriksaanPerutEntity  extends SystemArrayObject {
    protected $fields = [
		"ID"=>1     
		,"KUNJUNGAN"=>1     
		,"PENDAFTARAN"=>1     
		,"ABDOMEN_DISTENDED"=>1     
		,"ABDOMEN_METEORISMUS"=>1     
		,"PERISTALTIK_NORMAL"=>1     
		,"PERISTALTIK_MENINGKAT"=>1     
		,"PERISTALTIK_MENURUN"=>1     
		,"PERISTALTIK_TIDAK_ADA"=>1     
		,"ASITES"=>1     
		,"NYERI_TEKAN"=>1     
		,"NYERI_TEKAN_LOKASI"=>1     
		,"HEPAR"=>1     
		,"LIEN"=>1     
		,"EXTREMITAS_HANGAT"=>1     
		,"EXTREMITAS_DINGIN"=>1     
		,"UDEM"=>1     
		,"UDEM_DEKSRIPSI"=>1     
		,"LAIN_LAIN"=>1     
		,"DEFEKASI_ANUS"=>1     
		,"DEFEKASI_ANUS_FREKUENSI"=>1     
		,"DEFEKASI_ANUS_KONSISTENSI"=>1     
		,"DEFEKASI_STOMA"=>1     
		,"DEFEKASI_STOMA_DESKRIPSI"=>1     
		,"URIN_SPONTAN"=>1     
		,"URIN_KATETER"=>1     
		,"URIN_CYTOSTOMY"=>1     
		,"KELAINAN"=>1     
		,"KELAINAN_DESKRIPSI"=>1     
		,"ADA_KELAINAN"=>1     
		,"DESKRIPSI"=>1     
		,"TANGGAL"=>1     
		,"OLEH"=>1     
		,"STATUS"=>1  
	];
}
