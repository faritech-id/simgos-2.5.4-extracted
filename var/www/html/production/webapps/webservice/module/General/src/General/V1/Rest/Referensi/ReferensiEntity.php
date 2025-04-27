<?php
namespace General\V1\Rest\Referensi;
use DBService\SystemArrayObject;

class ReferensiEntity extends SystemArrayObject
{
	protected $fields = [
		'TABEL_ID'=>1,
		'JENIS'=>1,
		'ID'=>1,
		'DESKRIPSI'=>1,
		'REF_ID'=>1,
		'TEKS'=>1,
		'CONFIG'=>1,
		'STATUS'=>1
	];
}
