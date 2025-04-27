<?php
namespace LISService\winacom\dbservice\orderitem;
use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		'order_number'=>1,
		'order_item_id'=>1,
		'order_item_name'=>1,
		'order_item_datetime'=>1,
		'order_status'=>1
	];
}

