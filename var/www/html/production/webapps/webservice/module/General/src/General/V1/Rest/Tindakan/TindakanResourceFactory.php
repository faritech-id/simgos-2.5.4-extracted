<?php
namespace General\V1\Rest\Tindakan;

class TindakanResourceFactory
{
    public function __invoke($services)
    {
        $obj = new TindakanResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
