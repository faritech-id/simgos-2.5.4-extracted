<?php
namespace General\V1\Rest\PpnPenjualan;
use DBService\SystemArrayObject;

class PpnPenjualanEntity extends SystemArrayObject
{
	protected $fields = [
		"ID" => 1
		, "PPN" => 1
		, "NO_SK" => 1
        , "TANGGAL_MULAI_BERLAKU" => 1
        , "STATUS" => 1
        , "OLEH" => 1
	];
}