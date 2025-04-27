<?php
namespace Aplikasi\V1\Rest\AllowIP;

use DBService\SystemArrayObject;

class AllowIPEntity extends SystemArrayObject
{
    protected $fields = [
        "ID" => 1
		, "NOMOR" => [
			"DESCRIPTION" => "IP Domain",
			"FILTERS" => [
				0 => [
					'NAME' => '\\DBService\\filter\\Trim',
				],
			],
			"VALIDATORS" => [
				0 => [
					'NAME' => '\\DBService\\validator\\Alnum',
                    'OPTIONS' => [
						'allowCharacter' => ':.\-\s',
                        'notAlnumMessage' => 'Input yang di masukan harus berisi alfabet, angka, titik, minus dan spasi',
					],
				],
			],
		]
        , "DESKRIPSI" => [
			"DESCRIPTION" => "Deskripsi",
			"FILTERS" => [
				0 => [
					'NAME' => '\\DBService\\filter\\Trim',
				],
			],
			"VALIDATORS" => [
				0 => [
					'NAME' => '\\DBService\\validator\\Alpha',
                    'OPTIONS' => [
						'allowCharacter' => ".\s",
						'notAlnumMessage' => "Input yang di masukan harus berisi huruf, titik dan spasi",
					],
				],
			],
		]
        , "TANGGAL" => 1
        , "OLEH" => 1
        , "STATUS" => 1
    ];
}
