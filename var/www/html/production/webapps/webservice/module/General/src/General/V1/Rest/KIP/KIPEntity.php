<?php
namespace General\V1\Rest\KIP;
use DBService\SystemArrayObject;

class KIPEntity extends SystemArrayObject
{
	protected $title = "Kartu Identitas Pasien";
	protected $fields = [
		'JENIS' => [
            "DESCRIPTION" => "Jenis"
        ],
		'NORM' => [
            "DESCRIPTION" => "Nomor Rekam Medis"
        ],
		'NOMOR' => [
			"DESCRIPTION" => "Nomor",
			"FILTERS" => [
				0 => [
					'NAME' => '\\DBService\\filter\\Trim'
				],
			],
			"VALIDATORS" => [
				0 => [
					'NAME' => '\\DBService\\validator\\Alnum',
					'OPTIONS' => [
						'allowCharacter' => '.\-\/',
						'notAlnumMessage' => 'Input yang di masukan harus berisi huruf, angka, titik(.), minus(-) dan garis miring (/)'
					]
				]
			]
		],
		'ALAMAT' => [
            "DESCRIPTION" => "Alamat",
            "FILTERS" => [
				0 => [
					'NAME' => '\\DBService\\filter\\Trim'
				]
			],
			"VALIDATORS" => [
				0 => [
					'NAME' => '\\DBService\\validator\\Alnum',
                    'OPTIONS' => [
                        'allowCharacter' => '.\s',
                        'notAlnumMessage' => 'Input yang di masukan harus berisi huruf, angka, titik(.) dan spasi'
                    ]
				]
			]
        ],
		'RT' => [
			"DESCRIPTION" => "RT",
			"VALIDATORS" => [
				0 => [
					'NAME' => '\\DBService\\validator\\Number'
				]
			]
		],
		'RW' => [
			"DESCRIPTION" => "RW",
			"VALIDATORS" => [
				0 => [
					'NAME' => '\\DBService\\validator\\Number'
				]
			]
		],
		'KODEPOS' => [
			"DESCRIPTION" => "Kode Pos",
			"VALIDATORS" => [
				0 => [
					'NAME' => '\\DBService\\validator\\Number'
				]
			]
		],
		'WILAYAH' => [
            "DESCRIPTION" => "Kode Wilayah"
        ]
	];
	
	public function getNorm() {
		return isset($this->storage['NORM']) ? $this->storage['NORM'] : 0;
	}
}

