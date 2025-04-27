<?php
namespace General\V1\Rest\PPK;
use DBService\SystemArrayObject;

class PPKEntity extends SystemArrayObject
{
	protected $fields = [
		'ID'=>1, 
		'KODE'=> [
			"DESCRIPTION" => "Kode Faskes Kemkes",
			"FILTERS" => [
				0 => [
					'NAME' => '\\DBService\\filter\\Trim'
				],
				1 => [
					'NAME' => '\\DBService\\filter\\Alnum'
				]
			],
			"VALIDATORS" => [
				0 => [
					'NAME' => '\\DBService\\validator\\Alnum'
				]
			]
		], 
		'BPJS'=>[
			"DESCRIPTION" => "Kode Faskes BPJS",
			"FILTERS" => [
				0 => [
					'NAME' => '\\DBService\\filter\\Trim'
				],
				1 => [
					'NAME' => '\\DBService\\filter\\Alnum'
				]
			],
			"VALIDATORS" => [
				0 => [
					'NAME' => '\\DBService\\validator\\Alnum'
				]
			]
		],
		'JENIS'=> [
			"DESCRIPTION" => "Jenis PPK"
		],
		'KEPEMILIKAN'=>1, 
		'JPK'=>1,
        'NAMA'=>[
			"DESCRIPTION" => "Nama Faskes",
			"FILTERS" => [
				0 => [
					'NAME' => '\\DBService\\filter\\Trim'
				],
				1 => [
					'NAME' => '\\DBService\\filter\\Alnum',
					'OPTIONS' => [
						'allowCharacter' => '.\s'
					]
				]
			],
			"VALIDATORS" => [
				0 => [
					'NAME' => '\\DBService\\validator\\Alnum',
					'OPTIONS' => [
						'allowCharacter' => '.\s',
						'notAlnumMessage' => 'Input yang di masukan harus berisi alfabet, angka, titik dan spasi'
					]
				]
			]
		], 
		'KELAS'=>1, 
		'ALAMAT'=>[
			"DESCRIPTION" => "Alamat",
			"FILTERS" => [
				0 => [
					'NAME' => '\\DBService\\filter\\Trim'
				],
				1 => [
					'NAME' => '\\DBService\\filter\\Alnum',
					'OPTIONS' => [
						'allowCharacter' => '.\s'
					]
				]
			],
			"VALIDATORS" => [
				0 => [
					'NAME' => '\\DBService\\validator\\Alnum',
					'OPTIONS' => [
						'allowCharacter' => '.\s',
						'notAlnumMessage' => 'Input yang di masukan harus berisi alfabet, angka, titik dan spasi'
					]
				]
			]
		],
		'RT'=>[
			"DESCRIPTION" => "RT",
			"VALIDATORS" => [
				0 => [
					'NAME' => '\\DBService\\validator\\Number'
				]
			]
		],
		'RW'=>[
			"DESCRIPTION" => "RW",
			"VALIDATORS" => [
				0 => [
					'NAME' => '\\DBService\\validator\\Number'
				]
			]
		],
		'KODEPOS'=>[
			"DESCRIPTION" => "Kodepos",
			"VALIDATORS" => [
				0 => [
					'NAME' => '\\DBService\\validator\\Number'
				]
			]
		],
		'TELEPON'=>[
			"DESCRIPTION" => "Telepon",
			"VALIDATORS" => [
				0 => [
					'NAME' => '\\DBService\\validator\\Number',
					'OPTIONS' => [
						'allowCharacter' => '()\-\s',
						'notNumberMessage' => 'Input yang di masukan harus berisi angka, spasi, () dan -'
					]
				]
			]
		],
		'FAX'=>[
			"DESCRIPTION" => "Fax",
			"VALIDATORS" => [
				0 => [
					'NAME' => '\\DBService\\validator\\Regex',
					'OPTIONS' => [
						'pattern' => '/[0-9()\-\s]/u',
						'notRegexMessage' => 'Input yang di masukan harus berisi angka, spasi, () dan -'
					]
				]
			]
		],
        'WILAYAH'=>[
			"DESCRIPTION" => "Kode Wilayah"
		], 
		'DESWILAYAH'=> [
			"DESCRIPTION" => "Nama Wilayah"
		], 
		'MULAI'=>1, 
		'BERAKHIR'=>1, 
		'TANGGAL'=>1,
		'OLEH'=>1,
		'STATUS'=>1
	];
}
