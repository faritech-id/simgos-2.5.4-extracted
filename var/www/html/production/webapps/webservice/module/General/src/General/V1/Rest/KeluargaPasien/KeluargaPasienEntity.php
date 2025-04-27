<?php
namespace General\V1\Rest\KeluargaPasien;
use DBService\SystemArrayObject;

class KeluargaPasienEntity extends SystemArrayObject
{
	protected $title = "Keluarga Pasien";
	protected $fields = [
		'ID' => 1,
		'SHDK' => [
            "DESCRIPTION" => "Status Hubungan Dalam Keluarga (SHDK)"
        ],
		'NORM' => [
            "DESCRIPTION" => "Nomor Rekam Medis"
        ], 
		'JENIS_KELAMIN' => [
            "DESCRIPTION" => "Jenis Kelamin"
        ],
		'NOMOR' => 1,
		'NAMA' => [
			"DESCRIPTION" => "Nama",
            "FILTERS" => [
				0 => [
					'NAME' => '\\DBService\\filter\\Trim'
				]
			],
			"VALIDATORS" => [
				0 => [
					'NAME' => '\\DBService\\validator\\Alpha',
					'OPTIONS' => [
						'allowCharacter' => "'\s",
						'notAlnumMessage' => "Input yang di masukan harus berisi huruf, petik satu (') dan spasi"
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
		'PENDIDIKAN' => [
            "DESCRIPTION" => "Pendidikan"
        ],
		'PEKERJAAN' => [
            "DESCRIPTION" => "Pekerjaan"
        ],
		'TANGGAL_LAHIR' => [
            "DESCRIPTION" => "Tanggal Lahir"
        ]
	];
}
