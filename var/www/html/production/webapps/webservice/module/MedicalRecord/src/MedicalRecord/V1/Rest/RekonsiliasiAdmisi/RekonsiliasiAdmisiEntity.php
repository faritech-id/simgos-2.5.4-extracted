<?php
namespace MedicalRecord\V1\Rest\RekonsiliasiAdmisi;
use DBService\SystemArrayObject;

class RekonsiliasiAdmisiEntity extends SystemArrayObject
{
	protected $fields = array('ID'=>1, 'KUNJUNGAN'=>1, 'PENDAFTARAN'=>1, 'TIDAK_MENGGUNAKAN_OBAT_SEBELUM_ADMISI'=>1, 'TANGGAL'=>1, 'OLEH'=>1, 'STATUS'=>1);
}
