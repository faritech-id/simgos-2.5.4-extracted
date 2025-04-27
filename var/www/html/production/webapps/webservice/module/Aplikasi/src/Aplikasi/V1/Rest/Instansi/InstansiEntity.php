<?php
namespace Aplikasi\V1\Rest\Instansi;

use DBService\SystemArrayObject;

class InstansiEntity extends SystemArrayObject
{
    protected $fields = [
        "ID" => 1,
		"PPK" => 1,
        "EMAIL" => 1,
        "WEBSITE" => 1,
        "DEPARTEMEN" => 1,
        "INDUK_INSTANSI" => 1,
        "LOGO_GABUNG_NAMA" => 1
    ];
}
