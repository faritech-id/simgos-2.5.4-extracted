<?php
namespace INACBGService\V1\Rest\ICDINAGrouper;
use DBService\SystemArrayObject;

class ICDINAGrouperEntity extends SystemArrayObject
{
	protected $fields = [
        "code" => 1
		, "description" => 1
		, "validcode" => 1
		, "accpdx" => 1
		, "code_asterisk" => 1
		, "asterisk" => 1
		, "im" => 1
		, "icd_type" => 1	
    ];
}
