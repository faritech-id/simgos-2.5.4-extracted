<?php
namespace Layanan\V1\Rest\OrderDetilResep;

class OrderDetilResepResourceFactory
{
    public function __invoke($services)
    {
        $obj = new OrderDetilResepResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
