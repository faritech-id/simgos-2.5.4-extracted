<?php
namespace LISService\V1\Rest\HasilLog;

class HasilLogResourceFactory
{
    public function __invoke($services)
    {
        $obj = new HasilLogResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
