<?php
namespace MedicalRecord\V1\Rest\RekonsiliasiAdmisiDetil;
use DBService\SystemArrayObject;

class RekonsiliasiAdmisiDetilEntity extends SystemArrayObject
{
	protected $fields = array('ID'=>1, 'REKONSILIASI_ADMISI'=>1, 'OBAT_DARI_LUAR'=>1, 'DOSIS'=>1, 'FREKUENSI'=>1, 'RUTE'=>1, 'TINDAK_LANJUT'=>1, 
								'PERUBAHAN_ATURAN_PAKAI'=>1, 'STATUS'=>1, 'INPUT_ASAL'=>1, 'LAYANAN_FARMASI'=>1, 'RIWAYAT_PEMBERIAN_OBAT'=>1);
}
