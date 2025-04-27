<?php
namespace MedicalRecord\V1\Rest\RekonsiliasiTransferDetil;
use DBService\SystemArrayObject;

class RekonsiliasiTransferDetilEntity extends SystemArrayObject
{
	protected $fields = array('ID'=>1, 'REKONSILIASI_TRANSFER'=>1, 'OBAT_DARI_LUAR'=>1, 'DOSIS'=>1, 'FREKUENSI'=>1, 'RUTE'=>1, 'TINDAK_LANJUT'=>1
							, 'PERUBAHAN_ATURAN_PAKAI'=>1, 'STATUS'=>1, 'INPUT_ASAL'=>1, 'REKONSILIASI_ADMISI_DETIL'=>1, 'LAYANAN_FARMASI'=>1, 'REKONSILIASI_TRANSFER_DETIL'=>1);
}
