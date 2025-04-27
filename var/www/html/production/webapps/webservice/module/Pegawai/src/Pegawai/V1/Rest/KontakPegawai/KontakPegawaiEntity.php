<?php
namespace Pegawai\V1\Rest\KontakPegawai;
use DBService\SystemArrayObject;

class KontakPegawaiEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1
		, "JENIS"=>1
		, "NIP"=>1
		, "NOMOR"=>[
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
						// Validasi karakter yang di Input
						'allowCharacter' => '.@-',
						'notAlnumMessage' => 'Inputan yang di masukan harus berisi huruf, angka, titik(.), minus(-), @'
					]
				]
			]
		]
		, "STATUS"=>1
	];
}
