<?php
namespace Kemkes\IHS\V1\Rest\Loinc;
use DBService\SystemArrayObject;

class LoincEntity extends SystemArrayObject
{
    protected $fields = [
        'id' => 1,
        'kategori_pemeriksaan' => 1,
        'nama_pemeriksaan' => 1,
        'permintaan_hasil' => 1,
        'spesimen' => 1,
        'tipe_hasil_pemeriksaan' => 1,
        'satuan' => 1,
        'metode_analisis' => 1,
        'code' => 1,
        'display' => 1,
        'component' => 1,
        'property' => 1,
        'timing' => 1,
        'system' => 1,
        'scale' => 1,
        'method' => 1,
        'unit_of_measure' => 1,
        'code_system' => 1,
        'body_site_code' =>1 ,
        'body_site_display' => 1,
        'body_site_code_sistem' => 1,
        'version_first_released' => 1,
        'version_last_changed' => 1
    ];
}
