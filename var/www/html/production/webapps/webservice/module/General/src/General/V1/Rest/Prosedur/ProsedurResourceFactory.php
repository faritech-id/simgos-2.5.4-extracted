<?php
namespace General\V1\Rest\Prosedur;

class ProsedurResourceFactory
{
    public function __invoke($services)
    {
        $obj = new ProsedurResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
