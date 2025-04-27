<?php
namespace MedicalRecord\V1\Rest\MappingIndikatorDiagnosa;
use DBService\SystemArrayObject;
class MappingIndikatorDiagnosaEntity extends SystemArrayObject
{
    protected $fields = [
        "ID" => 1
        , "JENIS" => 1
        , "INDIKATOR" => 1
        , "DIAGNOSA" => 1
        , "STATUS" => 1
    ];
}
