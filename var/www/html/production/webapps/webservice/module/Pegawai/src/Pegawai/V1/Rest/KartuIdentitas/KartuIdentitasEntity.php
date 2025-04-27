<?php
namespace Pegawai\V1\Rest\KartuIdentitas;
use DBService\SystemArrayObject;

class KartuIdentitasEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1
		,"JENIS"=>1
		, "NIP"=>1
		, "NOMOR"=>[
			"DESCRIPTION" => "Nomor Kartu",
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
						'allowCharacter' => '\/.-',
						'notAlnumMessage' => 'Inputan yang di masukan harus berisi huruf, angka, titik(.), minus(-), garis miring (/)'
					]
				]
			]
		]
		, "ALAMAT"=>[
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
						'notAlnumMessage' => 'Inputan yang di masukan harus berisi huruf, angka, titik(.) dan spasi'
					]
				]
			]
		]
		, "RT"=>[
			"DESCRIPTION" => "RT",
			"VALIDATORS" => [
				0 => [
					'NAME' => '\\DBService\\validator\\Number',
				]
			]
		]
		, "RW"=>[
			"DESCRIPTION" => "RW",
			"VALIDATORS" => [
				0 => [
					'NAME' => '\\DBService\\validator\\Number',
				]
			]
		]
		, 'KODEPOS'=>[
			"DESCRIPTION" => "Kodepos",
			"VALIDATORS" => [
				0 => [
					'NAME' => '\\DBService\\validator\\Number',
				]
			]
		]
		, "WILAYAH"=>1
	];
}
