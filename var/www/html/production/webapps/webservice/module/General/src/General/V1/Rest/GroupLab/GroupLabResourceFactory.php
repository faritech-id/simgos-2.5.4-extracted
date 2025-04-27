<?php
namespace General\V1\Rest\GroupLab;

class GroupLabResourceFactory
{
    public function __invoke($services)
    {
        $obj = new GroupLabResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
