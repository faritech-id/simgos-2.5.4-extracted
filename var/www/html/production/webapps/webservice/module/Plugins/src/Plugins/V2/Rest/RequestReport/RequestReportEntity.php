<?php
namespace Plugins\V2\Rest\RequestReport;

use DBService\SystemArrayObject;

class RequestReportEntity extends SystemArrayObject
{
	protected $title = "Request Report";
    protected $fields =[
        'NAME' => [
			"REQUIRED" => true,
        ],
        'CONNECTION_NUMBER' => [
			"REQUIRED" => true,
        ],
        'TYPE' => [
			"REQUIRED" => true,
        ],
        'PARAMETER' => [
			"REQUIRED" => true,
        ],
        'REQUEST_FOR_PRINT' => [
			"REQUIRED" => true,
        ],
    ];		
}
