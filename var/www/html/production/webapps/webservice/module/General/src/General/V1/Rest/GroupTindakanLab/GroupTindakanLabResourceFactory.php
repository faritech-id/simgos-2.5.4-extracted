<?php
namespace General\V1\Rest\GroupTindakanLab;

class GroupTindakanLabResourceFactory
{
    public function __invoke($services)
    {
        $obj = new GroupTindakanLabResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
