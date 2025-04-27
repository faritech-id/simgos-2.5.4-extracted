<?php
namespace General\V1\Rest\TemplateAnatomi;
use DBService\SystemArrayObject;

class TemplateAnatomiEntity extends SystemArrayObject
{
    protected $fields = [
		"ID"=>1
		, "KSM"=>1
		, "NAMA"=>1
		, "TEMPLATE"=>1
		, "TYPE"=>1
		, "ORIENTATION"=>1
		, "STATUS"=>1
	];
}
