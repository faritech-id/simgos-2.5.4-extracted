<?php
namespace General\V1\Rest\JenisLaporanDetil;
use DBService\SystemArrayObject;

class JenisLaporanDetilEntity extends SystemArrayObject
{
	protected $fields = [
		'JENIS'=>1, 
		'ID'=>1, 
		'DESKRIPSI'=>1, 
		'KODE'=>1, 
		'REPORT_PARAMS'=>1,
		'KETERANGAN'=>1, 
		'STATUS'=>1
	];
}
