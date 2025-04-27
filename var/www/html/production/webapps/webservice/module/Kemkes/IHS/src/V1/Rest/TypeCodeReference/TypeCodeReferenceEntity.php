<?php
namespace Kemkes\IHS\V1\Rest\TypeCodeReference;
use DBService\SystemArrayObject;

class TypeCodeReferenceEntity extends SystemArrayObject
{
    protected $fields = [
        'type' => 1
        , 'id' => 1
        , 'code' => 1
        , 'display' => 1
        , 'system' => 1
        , 'status' => 1
    ];
}
