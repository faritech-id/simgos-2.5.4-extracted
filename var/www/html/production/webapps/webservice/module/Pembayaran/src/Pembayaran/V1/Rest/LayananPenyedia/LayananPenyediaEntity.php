<?php
namespace Pembayaran\V1\Rest\LayananPenyedia;

use DBService\SystemArrayObject;

class LayananPenyediaEntity extends SystemArrayObject
{
    protected $fields = [
		"ID"=>1
		, "PENYEDIA_ID"=>1
		, "JENIS_LAYANAN_ID"=>1
		, "DRIVER"=>1
		, "KODE"=>1
        , "STATUS_ID"=>1
	];
}
