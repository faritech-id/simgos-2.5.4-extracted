<?php
namespace Pembayaran\V1\Rest\Penyedia;

use DBService\SystemArrayObject;

class PenyediaEntity extends SystemArrayObject
{
    protected $fields = [
		"ID"=>1
		, "NAMA"=>1
		, "JENIS_PENYEDIA_ID"=>1
		, "REFERENSI_ID"=>1
		, "STATUS_ID"=>1
	];
}
