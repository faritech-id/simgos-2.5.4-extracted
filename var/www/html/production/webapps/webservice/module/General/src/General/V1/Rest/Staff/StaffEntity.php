<?php
namespace General\V1\Rest\Staff;

use DBService\SystemArrayObject;

class StaffEntity extends SystemArrayObject
{
    protected $fields = [
		'ID' => 1,
		'NIP' => 1,
		'STATUS' => 1
	];
}
