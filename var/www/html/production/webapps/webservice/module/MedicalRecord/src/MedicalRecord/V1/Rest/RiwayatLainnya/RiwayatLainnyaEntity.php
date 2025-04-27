<?php
namespace MedicalRecord\V1\Rest\RiwayatLainnya;
use DBService\SystemArrayObject;

class RiwayatLainnyaEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1
		, "KUNJUNGAN"=>1
		, "MEROKOK"=>1
		, "TERPAPAR_ASAP_ROKOK"=>1
		, "TANGGAL"=>1
		, "OLEH"=>1
		, "STATUS"=>1
	];
}
