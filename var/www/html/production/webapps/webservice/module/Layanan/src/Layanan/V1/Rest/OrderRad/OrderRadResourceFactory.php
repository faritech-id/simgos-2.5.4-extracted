<?php
namespace Layanan\V1\Rest\OrderRad;

class OrderRadResourceFactory
{
    public function __invoke($services)
    {
        $obj = new OrderRadResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
