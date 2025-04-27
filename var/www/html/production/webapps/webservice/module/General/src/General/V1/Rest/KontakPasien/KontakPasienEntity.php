<?php
namespace General\V1\Rest\KontakPasien;
use DBService\SystemArrayObject;

class KontakPasienEntity extends SystemArrayObject
{
	protected $title = "Kontak Pasien";
	protected $fields = [
		'JENIS' => [
            "DESCRIPTION" => "Jenis"
        ],
		'NORM' => [
            "DESCRIPTION" => "Nomor Rekam Medis"
        ],
		'NOMOR'=>[
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
						'allowCharacter' => '.@\-',
						'notAlnumMessage' => 'Inputan yang di masukan harus berisi huruf, angka, titik(.), minus(-), @'
					]
				]
			]
		]
	];
	
	public function getNorm() {
		return isset($this->storage['NORM']) ? $this->storage['NORM'] : 0;
	}
}

