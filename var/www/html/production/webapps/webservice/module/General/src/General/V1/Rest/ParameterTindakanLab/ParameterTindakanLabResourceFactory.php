<?php
namespace General\V1\Rest\ParameterTindakanLab;

class ParameterTindakanLabResourceFactory
{
    public function __invoke($services)
    {
        $obj = new ParameterTindakanLabResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
