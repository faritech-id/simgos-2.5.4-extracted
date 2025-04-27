<?php
namespace General\V1\Rest\Pegawai;
use DBService\SystemArrayObject;

class PegawaiEntity extends SystemArrayObject
{
	protected $fields = [
        'ID' => 1,
        'NIP'=>[
            "DESCRIPTION" => "Nip",
            "FILTERS" => [
                0 => [
                    'NAME' => '\\DBService\\filter\\Trim'
                ],
            ],
            "VALIDATORS" => [
                0 => [
                    'NAME' => '\\DBService\\validator\\Alnum',
                    'OPTIONS' => [
                        'notAlnumMessage' => 'Input yang di masukan harus berisi huruf dan angka'
                    ]
                ]
            ]
        ],
        'NAMA'=>[
            "DESCRIPTION" => "Nama",
            "FILTERS" => [
                0 => [
                    'NAME' => '\\DBService\\filter\\Trim'
                ],
            ],
            "VALIDATORS" => [
                0 => [
                    'NAME' => '\\DBService\\validator\\Alpha',
                    'OPTIONS' => [
                        // Validasi karakter yang di Input
                        'allowCharacter' => "'\s",
                        'notAlphaMessage' => "Input yang di masukan harus berisi huruf, petik satu (') dan spasi"
                    ]
                ]
            ]
        ], 
        'PANGGILAN'=>[
            "DESCRIPTION" => "Nama Panggilan",
            "FILTERS" => [
                0 => [
                    'NAME' => '\\DBService\\filter\\Trim'
                ],
            ],
            "VALIDATORS" => [
                0 => [
                    'NAME' => '\\DBService\\validator\\Alpha',
                    'OPTIONS' => [
                        // Validasi karakter yang di Input
                        'allowCharacter' => "'\s",
                        'notAlphaMessage' => "Input yang di masukan harus berisi huruf, petik satu (') dan spasi"
                    ]
                ]
            ]
        ],
        'GELAR_DEPAN'=>[
            "DESCRIPTION" => "Gelar Depan",
            "FILTERS" => [
                0 => [
                    'NAME' => '\\DBService\\filter\\Trim'
                ],
            ],
            "VALIDATORS" => [
                0 => [
                    'NAME' => '\\DBService\\validator\\Alpha',
                    'OPTIONS' => [
                        // Validasi karakter yang di Input
                        'allowCharacter' => '.\s',
                        'notAlphaMessage' => 'Input yang di masukan harus berisi huruf, titik (.), dan spasi'
                    ]
                ]
            ]
        ], 
        'GELAR_BELAKANG'=>[
            "DESCRIPTION" => "Gelar Belakang",
            "FILTERS" => [
                0 => [
                    'NAME' => '\\DBService\\filter\\Trim'
                ],
            ],
            "VALIDATORS" => [
                0 => [
                    'NAME' => '\\DBService\\validator\\Alpha',
                    'OPTIONS' => [
                        'allowCharacter' => '(),.\s',
                        'notAlphaMessage' => 'Input yang di masukan harus berisi huruf, titik (.), koma (,) dan spasi'
                    ]
                ]
            ]
        ], 
        'TEMPAT_LAHIR'=>[
            "DESCRIPTION" => "Tempat Lahir",
            "FILTERS" => [
                0 => [
                    'NAME' => '\\DBService\\filter\\Trim'
                ],
            ],
            "VALIDATORS" => [
                0 => [
                    'NAME' => '\\DBService\\validator\\Alpha',
                    'OPTIONS' => [
                        // Validasi karakter yang di Input
                        'allowCharacter' => "'\s",
                        'notAlphaMessage' => "Input yang di masukan harus berisi huruf, petik satu (') dan spasi"
                    ]
                ]
            ]
        ],
        
        'TANGGAL_LAHIR'=>[
            "DESCRIPTION" => "Tanggal Lahir"
        ],
        'AGAMA'=>[
            "DESCRIPTION" => "Agama"
        ],
        'JENIS_KELAMIN'=>[
            "DESCRIPTION" => "Jenis Kelamin"
        ],
        'PROFESI'=>[
            "DESCRIPTION" => "Jenis Profesi"
        ], 
        'SMF'=>1,
        'ALAMAT'=>[
            "DESCRIPTION" => "Alamat",
            "FILTERS" => [
                0 => [
                    'NAME' => '\\DBService\\filter\\Trim'
                ],
            ],
            "VALIDATORS" => [
                0 => [
                    'NAME' => '\\DBService\\validator\\Alnum',
                    'OPTIONS' => [
                        // Validasi karakter yang di Input
                        'allowCharacter' => '.\s',
                        'notAlnumMessage' => 'Input yang di masukan harus berisi huruf, angka, titik(.) dan spasi'
                    ]
                ]
            ]
        ],
        'RT'=>[
            "DESCRIPTION" => "RT",
            "VALIDATORS" => [
                0 => [
                    'NAME' => '\\DBService\\validator\\Number',
                ]
            ]
        ],
        'RW'=>[
            "DESCRIPTION" => "RW",
            "VALIDATORS" => [
                0 => [
                    'NAME' => '\\DBService\\validator\\Number',
                ]
            ]
        ],
        'KODEPOS'=>[
            "DESCRIPTION" => "Kodepos",
            "VALIDATORS" => [
                0 => [
                    'NAME' => '\\DBService\\validator\\Number',
                ]
            ]
        ], 
        'WILAYAH'=>[
            "DESCRIPTION" => "Kode Wilayah"
        ], 
        'NON_PEGAWAI'=>[
            "DESCRIPTION" => "Non Pegawai"
        ], 
        'STATUS'=>1
    ];
}
