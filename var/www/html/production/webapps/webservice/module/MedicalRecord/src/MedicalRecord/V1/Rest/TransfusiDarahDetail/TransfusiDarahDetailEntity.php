<?php
namespace MedicalRecord\V1\Rest\TransfusiDarahDetail;
use DBService\SystemArrayObject;

class TransfusiDarahDetailEntity extends SystemArrayObject
{
	protected $fields = [
		'ID'=>1
		, 'TRANSFUSI_DARAH'=>1
		, 'NOMOR_KANTONG'=>1
		, 'TANGGAL_KADALUARSA'=>1
		, 'STATUS'=>1
	];
}