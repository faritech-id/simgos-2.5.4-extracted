<?php
namespace Pembayaran\V1\Rest\TagihanPendaftaran;
use DBService\SystemArrayObject;

class TagihanPendaftaranEntity extends SystemArrayObject
{
	protected $fields = [
		'ID'=>1,
		'TAGIHAN'=>1, 
		'PENDAFTARAN'=>1,
		'REF'=>1, 
		'UTAMA'=>1,
		'STATUS'=>1
	];
}
