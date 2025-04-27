<?php
namespace Kemkes\IHS\V1\Rest\CodeReference;
use DBService\SystemArrayObject;

class CodeReferenceEntity extends SystemArrayObject
{
    protected $fields = [
        'id' => 1
        , 'resources' => 1
        , 'entity' => 1
        , 'system' => 1
        , 'status' => 1
    ];
}
