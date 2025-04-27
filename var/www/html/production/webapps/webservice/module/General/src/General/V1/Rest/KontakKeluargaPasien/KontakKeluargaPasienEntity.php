<?php
namespace General\V1\Rest\KontakKeluargaPasien;
use DBService\SystemArrayObject;

class KontakKeluargaPasienEntity extends SystemArrayObject
{
	protected $fields = [
		'SHDK' => [
            "DESCRIPTION" => "Status Hubungan Dalam Keluarga"
        ],
		'JENIS' => [
            "DESCRIPTION" => "Jenis Kontak"
        ],
		'NORM' => [
            "DESCRIPTION" => "Nomor Rekam Medis"
        ],
		'NOMOR' => [
			"DESCRIPTION" => "Kontak keluarga",
			"VALIDATORS" => [
				0 => [
					'NAME' => '\\DBService\\validator\\Alnum',
					'OPTIONS' => [
						'allowCharacter' => '.@\-',
						'notAlnumMessage' => 'Inputan yang di masukan harus berisi huruf, angka, titik(.), minus(-), @'
					]
				]
			]
		]
	];
}

