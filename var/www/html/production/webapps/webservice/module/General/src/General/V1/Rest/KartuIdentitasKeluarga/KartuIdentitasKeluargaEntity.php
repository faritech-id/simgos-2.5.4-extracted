<?php
namespace General\V1\Rest\KartuIdentitasKeluarga;

use DBService\SystemArrayObject;

class KartuIdentitasKeluargaEntity extends SystemArrayObject
{
	protected $title = "Kartu Identitas Keluarga";
    protected $fields = [
        'ID' => 1,
		'JENIS' => [
            "DESCRIPTION" => "Jenis"
        ],
		'KELUARGA_PASIEN_ID' => [
            "DESCRIPTION" => "Keluarga Pasien Id"
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
            "DESCRIPTION" => "Nama",
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
}
