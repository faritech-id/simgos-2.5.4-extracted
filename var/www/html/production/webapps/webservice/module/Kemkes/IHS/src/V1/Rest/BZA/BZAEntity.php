<?php
namespace Kemkes\IHS\V1\Rest\BZA;
use DBService\SystemArrayObject;

class BZAEntity extends SystemArrayObject
{
    protected $fields = [
        'id' => 1
        , 'display' => 1
        , 'unit_of_mesure' => 1
        , 'url' => 1
        , 'status' => 1
    ];
}
