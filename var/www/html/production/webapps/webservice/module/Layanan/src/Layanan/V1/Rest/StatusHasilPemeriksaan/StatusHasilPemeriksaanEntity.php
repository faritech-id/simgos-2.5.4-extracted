<?php
namespace Layanan\V1\Rest\StatusHasilPemeriksaan;

use DBService\SystemArrayObject;

class StatusHasilPemeriksaanEntity extends SystemArrayObject
{
    protected $fields = [
		"ID" => 1,
		"TINDAKAN_MEDIS_ID" => 1,
		'JENIS' => 1,
		"STATUS_HASIL" => 1,
		"STATUS_PENGIRIMAN_HASIL" => 1,
		"TANGGAL_PENGIRIMAN_HASIL" => 1,
		"PENGIRIMAN_HASIL_OLEH" => [
            "DESCRIPTION" => "Pengiriman / Pengambilah Hasil Oleh",
            "FILTERS" => [
				0 => [
					'NAME' => '\\DBService\\filter\\Trim'
				]
			],
			"VALIDATORS" => [
				0 => [
					'NAME' => '\\DBService\\validator\\Alpha',
					'OPTIONS' => [
						'allowCharacter' => ".'\s",
						'notAlnumMessage' => "Input yang di masukan harus berisi huruf, titik, petik satu (') dan spasi"
					]
				]
			]
        ],
		"PPSPH" => 1,
		"STATUS_PEMERIKSAAN" => 1, // status foto utk radiologi (sdh ada / belum)
		"TANGGAL_PEMERIKSAAN" => 1,
		"PETUGAS_PEMERIKSAAN" => 1,
		"PPSP" => 1
	];
}
