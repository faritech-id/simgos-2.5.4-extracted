<?php
namespace General\V1\Rest\Pasien;
use DBService\SystemArrayObject;

class PasienEntity extends SystemArrayObject
{
	protected $title = "Pasien";
    protected $fields =[
        'NORM' => [
            "DESCRIPTION" => "Nomor Rekam Medis"
        ],
        'NAMA' => [
            "DESCRIPTION" => "Nama",
			"REQUIRED" => true,
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
        'PANGGILAN' => [
            "DESCRIPTION" => "Panggilan",
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
        'GELAR_DEPAN' => [
            "DESCRIPTION" => "Gelar Depan",
            "FILTERS" => [
				0 => [
					'NAME' => '\\DBService\\filter\\Trim'
				]
			],
			"VALIDATORS" => [
				0 => [
					'NAME' => '\\DBService\\validator\\Alpha',
					'OPTIONS' => [
						'allowCharacter' => '.\s',
						'notAlnumMessage' => 'Input yang di masukan harus berisi huruf, titik (.), dan spasi'
					]
				]
			]
        ],
		'GELAR_BELAKANG' => [
            "DESCRIPTION" => "Gelar Belakang",
            "FILTERS" => [
				0 => [
					'NAME' => '\\DBService\\filter\\Trim'
				]
			],
			"VALIDATORS" => [
				0 => [
					'NAME' => '\\DBService\\validator\\Alpha',
					'OPTIONS' => [
						'allowCharacter' => ',.\s',
						'notAlnumMessage' => 'Input yang di masukan harus berisi huruf, titik (.), koma (,) dan spasi'
					]
				]
			]
        ],
		'TEMPAT_LAHIR' => [
            "DESCRIPTION" => "Tempat Lahir",
            "FILTERS" => [
				0 => [
					'NAME' => '\\DBService\\filter\\Trim'
				]
			],
			"VALIDATORS" => [
				0 => [
					'NAME' => '\\DBService\\validator\\Alnum',
					'OPTIONS' => [
						'allowCharacter' => "'\s",
                        'notAlnumMessage' => "Input yang di masukan harus berisi huruf, petik satu ('), spasi atau kode kab/kota"
					]
				]
			]
        ],
		'TANGGAL_LAHIR' => [
            "DESCRIPTION" => "Tanggal Lahir"
        ],
		'JENIS_KELAMIN' => [
            "DESCRIPTION" => "Jenis Kelamin"
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
			"DESCRIPTION" => "Kodepos",
			"VALIDATORS" => [
				0 => [
					'NAME' => '\\DBService\\validator\\Number'
				]
			]
		],
		'WILAYAH' => [
            "DESCRIPTION" => "Kode Wilayah"
        ],
		'AGAMA' => [
            "DESCRIPTION" => "Agama"
        ],
		'PENDIDIKAN' => [
            "DESCRIPTION" => "Pendidikan"
        ],
		'PEKERJAAN' => [
            "DESCRIPTION" => "Pekerjaan"
        ],
		'STATUS_PERKAWINAN' => [
            "DESCRIPTION" => "Status Perkawinan"
        ],
		'GOLONGAN_DARAH' => [
            "DESCRIPTION" => "Golongan Darah"
        ],
		'KEWARGANEGARAAN' => [
            "DESCRIPTION" => "Kewarganegaraan"
        ],
		'SUKU' => [
            "DESCRIPTION" => "Suku"
        ],
		'BAHASA' => [
            "DESCRIPTION" => "Bahasa"
        ],
		'TIDAK_DIKENAL' => [
            "DESCRIPTION" => "Tidak Dikenal",
			"REQUIRED" => true
		],
		'TANGGAL' => 1, 
		'OLEH' => 1, 
		'STATUS' => 1
    ];
		
	public function getNorm() {
		return isset($this->storage['NORM']) ? $this->storage['NORM'] : 0;
	}
}
