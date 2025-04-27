<?php
namespace Kemkes\IHS\V1\Rest\POV;
use DBService\SystemArrayObject;

class POVEntity extends SystemArrayObject
{
    protected $fields = [
        'id' => 1
        , 'display' => 1
        , 'unit_of_mesure' => 1
        , 'jenis' => 1
        , 'url' => 1
        , 'status' => 1
    ];
}
