<?php
namespace Kemkes\IHS\V1\Rest\ParameterHasilToLoinc;
use DBService\SystemArrayObject;

class ParameterHasilToLoincEntity extends SystemArrayObject
{
    protected $fields = [
        "PARAMETER_HASIL" => 1,
        "LOINC_TERMINOLOGI" => 1,
        "STATUS" => 1
    ];
}
