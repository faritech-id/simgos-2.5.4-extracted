<?php
namespace MedicalRecord\V1\Rest\MappingIntervensiIndikator;
use DBService\SystemArrayObject;
class MappingIntervensiIndikatorEntity extends SystemArrayObject
{
    protected $fields = [
        "ID" => 1
        , "JENIS" => 1
        , "INDIKATOR" => 1
        , "INTERVENSI" => 1
        , "STATUS" => 1
    ];
}
