<?php
namespace Kemkes\IHS\V1\Rest\SnomedCt;
use DBService\SystemArrayObject;
class SnomedCtEntity extends SystemArrayObject
{
    protected $fields = [
        "id" => 1,
        "effectiveTime" => 1,
        "active" => 1,
        "moduleId" => 1,
        "conceptId" => 1,
        "languageCode" => 1,
        "typeId" => 1,
        "term" => 1,
        "caseSignificanceId" => 1,
    ];
}
