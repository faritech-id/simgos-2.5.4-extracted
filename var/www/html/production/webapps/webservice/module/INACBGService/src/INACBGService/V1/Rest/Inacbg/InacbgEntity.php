<?php
namespace INACBGService\V1\Rest\Inacbg;
use DBService\SystemArrayObject;

class InacbgEntity extends SystemArrayObject
{
	protected $fields = [
		'ID'=>1
		, 'JENIS'=>1
		, 'KODE'=>1
		, 'DESKRIPSI'=>1
		, 'VERSION'=>1
		, 'TANGGAL_BERLAKU'=>1		
	];
}
