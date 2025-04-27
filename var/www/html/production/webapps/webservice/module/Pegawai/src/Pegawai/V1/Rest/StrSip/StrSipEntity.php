<?php
namespace Pegawai\V1\Rest\StrSip;

use DBService\SystemArrayObject;

class StrSipEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1
		, "NIP"=>1
		, "JENIS"=>1
		, "NOMOR"=>1
		, "TANGGAL_BERLAKU"=>1
		, "BERLAKU_SAMPAI"=>1
		, "FILE"=>1
		, "TYPE"=>1
		, "TANGGAL"=>1
		, "STATUS"=>1
	];
}
