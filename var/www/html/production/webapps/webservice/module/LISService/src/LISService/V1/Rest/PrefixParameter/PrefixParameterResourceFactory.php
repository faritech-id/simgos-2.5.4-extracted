<?php
namespace LISService\V1\Rest\PrefixParameter;

class PrefixParameterResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PrefixParameterResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
