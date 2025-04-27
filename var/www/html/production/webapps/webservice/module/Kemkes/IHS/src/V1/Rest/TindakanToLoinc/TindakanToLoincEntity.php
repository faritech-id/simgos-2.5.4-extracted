<?php
namespace Kemkes\IHS\V1\Rest\TindakanToLoinc;
use DBService\SystemArrayObject;

class TindakanToLoincEntity extends SystemArrayObject
{
    protected $fields = [
        "TINDAKAN" => [
            "isKey" => true,
            "DESCRIPTION" => "tindakan"
        ],
        "LOINC_TERMINOLOGI" => 1,
        "SPESIMENT" => 1,
        "KATEGORI" => 1,
        "STATUS" => 1
    ];
}
