<?php
namespace MedicalRecord\V1\Rest\RekonsiliasiTransfer;
use DBService\SystemArrayObject;

class RekonsiliasiTransferEntity extends SystemArrayObject
{
	protected $fields = array('ID'=>1, 'KUNJUNGAN'=>1, 'PENDAFTARAN'=>1, 'TANGGAL'=>1, 'OLEH'=>1, 'STATUS'=>1);
}
