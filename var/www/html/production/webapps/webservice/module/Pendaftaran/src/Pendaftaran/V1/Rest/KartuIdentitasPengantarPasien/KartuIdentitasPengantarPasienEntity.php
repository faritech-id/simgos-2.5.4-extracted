<?php
namespace Pendaftaran\V1\Rest\KartuIdentitasPengantarPasien;
use DBService\SystemArrayObject;

class KartuIdentitasPengantarPasienEntity extends SystemArrayObject
{
	protected $fields = [
		'ID' => 1,
		'JENIS' => [
            "DESCRIPTION" => "Jenis Kartu Identitas Pasien"
        ],
		'PENGANTAR_ID' => [
            "DESCRIPTION" => "Pengantar Pasien Id"
        ],
		'NOMOR' => [
			"DESCRIPTION" => "Nomor Identitas",
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
            "DESCRIPTION" => "Nama Keluarga",
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
