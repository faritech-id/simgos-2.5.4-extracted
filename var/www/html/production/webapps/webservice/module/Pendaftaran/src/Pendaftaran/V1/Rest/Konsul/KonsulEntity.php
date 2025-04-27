<?php
namespace Pendaftaran\V1\Rest\Konsul;
use DBService\SystemArrayObject;

class KonsulEntity extends SystemArrayObject
{
	protected $fields = [
		'NOMOR' => 1, 
		'KUNJUNGAN' => 1, 
		'TANGGAL' => 1, 
		'DOKTER_ASAL' => 1, 
		'ALASAN' => 1,
		'PERMINTAAN_TINDAKAN' => 1, 
		'TUJUAN' => 1, 
		'OLEH' => 1, 
		'STATUS' => 1
	];
}
