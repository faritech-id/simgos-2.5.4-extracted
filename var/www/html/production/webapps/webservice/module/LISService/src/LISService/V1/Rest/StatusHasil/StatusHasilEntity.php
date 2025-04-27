<?php
namespace LISService\V1\Rest\StatusHasil;

use DBService\SystemArrayObject;

class StatusHasilEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1
		, "DESKRIPSI"=>1
		, "STATUS"=>1
	];
}
