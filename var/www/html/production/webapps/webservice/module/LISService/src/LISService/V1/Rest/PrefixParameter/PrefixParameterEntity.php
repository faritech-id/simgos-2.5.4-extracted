<?php
namespace LISService\V1\Rest\PrefixParameter;

use DBService\SystemArrayObject;

class PrefixParameterEntity extends SystemArrayObject
{
    protected $fields = [
		"ID"=>1
		, "VENDOR_ID"=>1
        , "KODE"=>1
        , "DESKRIPSI"=>1
		, "LIS_KODE_TEST"=>1
	];
}
