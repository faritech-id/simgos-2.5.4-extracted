<?php
namespace MedicalRecord\V1\Rest\RekonsiliasiDischarge;
use DBService\SystemArrayObject;

class RekonsiliasiDischargeEntity extends SystemArrayObject
{
	protected $fields = array('ID'=>1, 'KUNJUNGAN'=>1, 'PENDAFTARAN'=>1, 'TANGGAL'=>1, 'OLEH'=>1, 'STATUS'=>1);
}
