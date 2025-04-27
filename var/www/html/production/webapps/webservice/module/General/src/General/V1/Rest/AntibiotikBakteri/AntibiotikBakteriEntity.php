<?php
namespace General\V1\Rest\AntibiotikBakteri;
use DBService\SystemArrayObject;

class AntibiotikBakteriEntity extends SystemArrayObject
{
    protected $fields = [
        "ID"=>1
        , "BAKTERI"=>1
        , "ANTIBIOTIK"=>1
        , "STATUS"=>1
    ];
}
