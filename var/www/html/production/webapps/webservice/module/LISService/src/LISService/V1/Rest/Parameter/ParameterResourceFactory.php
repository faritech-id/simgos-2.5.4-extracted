<?php
namespace LISService\V1\Rest\Parameter;

class ParameterResourceFactory
{
    public function __invoke($services)
    {
        $obj = new ParameterResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
