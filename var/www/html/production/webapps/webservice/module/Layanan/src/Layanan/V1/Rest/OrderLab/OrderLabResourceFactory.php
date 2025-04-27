<?php
namespace Layanan\V1\Rest\OrderLab;

class OrderLabResourceFactory
{
    public function __invoke($services)
    {
        $obj = new OrderLabResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
