<?php
namespace General\V1\Rest\Refrl;

class RefrlResourceFactory
{
    public function __invoke($services)
    {
        $obj = new RefrlResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
