<?php
namespace LISService\V1\Rest\Parameter;

use DBService\SystemArrayObject;

class ParameterEntity extends SystemArrayObject
{
    protected $fields = [
		"ID"=>1
		, "VENDOR_ID"=>1
        , "KODE"=>1
        , "NAMA"=>1
		, "STATUS"=>1
	];
}
