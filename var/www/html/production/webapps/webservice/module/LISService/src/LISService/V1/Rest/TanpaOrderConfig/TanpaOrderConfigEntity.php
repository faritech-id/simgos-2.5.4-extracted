<?php
namespace LISService\V1\Rest\TanpaOrderConfig;

use DBService\SystemArrayObject;

class TanpaOrderConfigEntity extends SystemArrayObject
{
    protected $fields = [
		"ID"=>1
		, "RUANGAN_LAB" => [
            "DESCRIPTION" => "Ruangan Lab",
            "FILTERS" => [
				0 => [
					'NAME' => '\\DBService\\filter\\Trim'
				]
			],
			"VALIDATORS" => [
				0 => [
					'NAME' => '\\DBService\\validator\\Number'
				]
			]
        ]
		, "DOKTER_LAB"=>1
        , "ANALIS_LAB"=>1
        , "AUTO_FINAL_HASIL_GDS"=>1
	];
}
