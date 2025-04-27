<?php
namespace BerkasKlaim\V1\Rest\PatologiAnatomiDetil;
use DBService\SystemArrayObject;

class PatologiAnatomiDetilEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1
		, "PATOLOGI_ANATOMI"=>1
		, "HASIL_PA"=>1
		, "STATUS"=>1
	];
}
