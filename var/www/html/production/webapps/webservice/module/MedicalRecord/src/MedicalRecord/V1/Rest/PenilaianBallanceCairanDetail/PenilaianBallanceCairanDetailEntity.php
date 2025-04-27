<?php
namespace MedicalRecord\V1\Rest\PenilaianBallanceCairanDetail;
use DBService\SystemArrayObject;

class PenilaianBallanceCairanDetailEntity extends SystemArrayObject
{
	protected $fields = [
		'ID'=>1
		, 'BALLANCE_CAIRAN'=>1
		, 'KELOMPOK'=>1
		, 'DESKRIPSI'=>1
		, 'JUMLAH'=>1
		, 'STATUS'=>1
	];
}