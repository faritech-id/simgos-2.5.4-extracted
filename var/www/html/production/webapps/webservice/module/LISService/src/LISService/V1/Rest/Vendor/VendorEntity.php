<?php
namespace LISService\V1\Rest\Vendor;

use DBService\SystemArrayObject;

class VendorEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1
		, "NAMA"=>1
		, "STATUS"=>1
	];
}
